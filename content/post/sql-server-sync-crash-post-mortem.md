---
title: "记一次大数据量同步导致的 SQL Server 崩溃与全线服务掉线复盘"
date: 2026-05-27T10:00:00+08:00
draft: false
tags: ["SQL Server", "PostgreSQL", "Docker", "SRE", "Post-mortem"]
categories: ["Database", "Ops"]
---

## 0. 背景

最近在进行项目迁移，需要将数据 from PostgreSQL 同步到 SQL Server。为了快速实现逻辑，编写了一个 Python 脚本 `sync_pg_to_mssql.py`，利用 Pandas 的 `read_sql_query` 配合 `to_sql` 进行分块同步。

然而，在一次针对包含千万级数据（尤其是含有 JSON 字段）的大表进行同步时，服务器突然“失联”，引发了一场连锁反应。

## 1. 问题表现

在执行同步脚本约 10 分钟后，出现了以下异常：
- **服务全线掉线**：Cloudflare Tunnel、frpc 和 Tailscale 等远程访问服务几乎同时失去连接。
- **SSH 响应极慢**：原本流畅的 SSH 终端开始出现数秒甚至数十秒的延迟。
- **监控中断**：所有运行在宿主机上的监控进程停止更新。
- **容器重启**：SQL Server 容器在崩溃后触发了自动重启。

## 2. 排查思路 & 经过

### 2.1 现场初步分析
通过内网环境（SSH -p 6000）勉强登录后，发现系统负载（Load Average）已经飙升到了一个恐怖的数值。查看 SQL Server 容器日志，发现了关键报错：

```text
Error: 701, Severity: 17, State: 123.
There is insufficient system memory in resource pool 'default' to run this query.
Long Sync IO: Scheduler 16 had 1 Sync IOs in nonpreemptive mode longer than 1000 ms
```

这表明系统不仅内存耗尽，磁盘 IO 也陷入了严重的阻塞。

### 2.2 sar 数据分析
由于系统在崩溃期间几乎无法操作，我们查阅了 `sysstat` 的历史记录（`sar`）。

在崩溃前的最后一秒（10:09:01 PM），数据如下：
- **内存使用率**：97.09%，Swap 占用：97.35%。系统已经进入了 **Thrashing（抖动）** 状态。
- **IO 等待 (%iowait)**：87.13%。这意味着 CPU 绝大部分时间都在等待磁盘写入完成。
- **负载 (Load Average)**：**474.52**（在 20 核机器上，这意味着近 450 个进程在排队）。

### 2.3 根因定位
1. **SQL Server 内存过度预留**：SQL Server 在 Linux 容器下默认会尝试预留尽可能多的物理内存。在没有配置 `MSSQL_MEMORY_LIMIT_MB` 的情况下，它与宿主机系统发生了激烈的内存抢占。
2. **Pandas 内存峰值**：脚本中 `chunksize=50000` 对于含有大量 JSON 字段的表来说过大。在处理 `json.dumps` 时，内存中产生了海量的字符串对象。
3. **IO 饱和与事务日志爆炸**：由于表数据量巨大（单表最高 58GB），`to_sql` 产生的海量同步 IO 彻底瘫痪了磁盘系统。
4. **OOM Killer 介入**：当内存和 Swap 同时耗尽，内核触发 OOM Killer 杀掉了占用资源或优先级较低的进程（包括 frpc 等隧道服务），导致全线掉线。

## 3. 反思与改进

### 3.1 容器化不代表可以忽视资源限制
在生产环境中，**永远不要在不设限的情况下运行 SQL Server 容器**。
- 必须设置 `MSSQL_MEMORY_LIMIT_MB` 环境参数。
- 在 Docker Compose 中应使用 `deploy.resources.limits` 明确限制内存。

### 3.2 代码层面的优化
- **减小分块大小**：针对宽表或含有 LOB/JSON 字段的表，应显著调小 `chunksize`。
- **使用更高效的同步方式**：对于 10GB 以上的表，应优先考虑 `BCP` 或 `BULK INSERT`，而不是通过 Pandas 中转。
- **开启驱动级优化**：例如 `fast_executemany=True` 以减少往返次数。

### 3.3 系统级监控预警
- **Swappiness 调整**：在高 IO 数据库场景下，应适当降低宿主机的 swappiness 值。
- **IO 等待告警**：当 `%iowait` 持续超过 20% 时应立即触发预警。

这次事故再次提醒我们：大数据量的同步不仅仅是代码逻辑问题，更是一场关于 CPU、内存与磁盘 IO 的资源博弈。
