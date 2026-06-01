---
title: "PostgreSQL 性能优化实录：从 25MB/s 到 Docker 连通性“陷阱”"
date: 2026-06-01T10:00:00+08:00
categories: ["Tech"]
tags: ["PostgreSQL", "Docker", "Database", "Optimization"]
author: "Paisen"
draft: false
---

## 背景：高性能硬件下的低速尴尬

在最近的一个项目中，我们部署了一套 PostgreSQL 17 数据库。硬件配置非常硬核：

*   **CPU**: 20 Cores
*   **Memory**: 32GB RAM
*   **Storage**: NVMe SSD

但在实际运行中，我们发现一个令人困惑的现象：在没有索引的情况下，全表扫描或复杂查询的 IO 吞吐量被死死限制在 **25MB/s** 左右。对于 NVMe 硬盘和 20 核 CPU 来说，这显然远未达到硬件上限。

## 第一步：针对性调优 (PGTune)

PostgreSQL 默认配置通常非常保守（为了兼容老旧机器）。为了榨干硬件性能，我们使用了业界公认的调优工具 [PGTune](https://pgtune.leopard.in.ua/)。

根据我们的硬件参数，PGTune 生成了一套优化建议，重点修改了以下参数：

*   `shared_buffers`: 提升到 8GB (25% RAM)
*   `effective_cache_size`: 24GB
*   `maintenance_work_mem`: 2GB
*   `max_parallel_workers_per_gather`: 针对 20 核进行了并行度优化
*   `random_page_cost`: 针对 NVMe 设置为 1.1

## 第二步：配置生效的“第一道坑”——挂载路径

由于数据库运行在 Docker 容器中，我们需要将自定义的 `postgresql.conf` 挂载进去。

**第一次尝试：**
参考了一些过时的文档，我将配置文件挂载到了：
`/etc/postgresql/postgresql.conf`

执行重启：
```bash
docker compose up -d --force-recreate
```

进入数据库检查配置：
```sql
show shared_buffers;
```

**结果：** 配置完全没生效，依然是默认的 `128MB`。

**原因分析：**
在官方 PostgreSQL Docker 镜像中，默认的配置文件实际上存放在数据目录 `$PGDATA` 中。如果你只是挂载到 `/etc/postgresql/`，容器启动时依然会读取 `/var/lib/postgresql/data/postgresql.conf`。

## 第三步：配置生效的“第二道坑”——无法连接

根据 Gemini 的建议，我修改了挂载路径，直接覆盖数据目录下的配置：
`./custom_postgres.conf:/var/lib/postgresql/data/postgresql.conf`

**第二次尝试：**
重启容器后，诡异的事情发生了：数据库确实启动了，但宿主机通过 `psql` 连接报错了：

```bash
psql: error: connection to server at "localhost" (::1), port 5432 failed: server closed the connection unexpectedly
```

明明容器状态是 `Up`，端口映射也正常，为什么连不上？

## 第四步：日志寻真，真相大白

我查看了容器日志：
```bash
docker logs postgis-server
```

日志显示了一行关键信息：
```text
2026-06-01 01:09:02.562 GMT [1] LOG:  listening on IPv4 address "127.0.0.1", port 5432
```

**破案了：**
1.  **默认行为：** PostgreSQL 官方镜像在没有提供自定义配置时，会自动设置 `listen_addresses = '*'`，以便允许来自容器外部（包括 Docker 网桥）的连接。
2.  **自定义覆盖：** 当我们挂载了由 PGTune 生成的 `postgresql.conf` 时，PGTune 的配置中**默认没有指定** `listen_addresses`。
3.  **内核默认：** PostgreSQL 内核本身的缺省值是 `localhost (127.0.0.1)`。

在 Docker 环境下，如果数据库只监听 `127.0.0.1`，那么它只能接受来自容器内部的请求。Docker 宿主机的端口转发请求会被拒绝，因为它被视为来自“外部接口”。

## 最终解决方案

在自定义的 `postgresql.conf` 顶部添加以下配置：

```conf
# 允许来自任何地址的连接，这在 Docker 环境下是必须的
listen_addresses = '*' 
```

保存并重启容器，问题完美解决。

## 总结

1.  **不要迷信默认配置：** 25MB/s 的上限通常是配置受限，而非硬件瓶颈。
2.  **Docker 挂载路径：** 官方 PostgreSQL 镜像的配置应挂载至 `/var/lib/postgresql/data/postgresql.conf`。
3.  **监听地址：** 在 Docker 中使用自定义配置时，务必手动加上 `listen_addresses = '*'`，否则你会陷入“容器活着却连不上”的死循环。

希望这次“填坑”经历能帮到正在优化数据库的你！
