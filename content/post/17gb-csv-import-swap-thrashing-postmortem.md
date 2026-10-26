---
title: "记一次 17GB CSV 导入打爆宿主机：从 SSH 失联到 swap 抖动的完整复盘"
date: 2026-10-26T10:50:00+08:00
draft: false
tags: ["PostgreSQL", "Pandas", "Swap", "OOM", "FRP", "Tailscale", "SRE", "Post-mortem"]
categories: ["Database", "Ops"]
---

## 0. 背景

`worker1` 是一台放在办公室的 Lenovo ThinkCentre K70-05 台式机（i5-14500 / 30GB RAM / Debian 13），被当作内网服务器使用，上面同时运行着：

- SQL Server 2022（容器）
- ClickHouse（容器）
- PostGIS / PostgreSQL 17（容器）
- Java 业务服务（4GB 堆）
- Nginx + Python 后端（容器）

对外通过 **frp 反向隧道**暴露：`aliyun:6000 → worker1:22`（SSH）、`8080`、`8100`、`15432`、`18123`，另有一条 Tailscale 作为备用通道。

当天需要把一份季度 POI 数据（CSV，17GB）导入 PostgreSQL。仓库里已有现成的 `import_to_pg.py`，直接执行：

```bash
python3 import_to_pg.py /data/tools/ko_poi_2026q3_release.csv --schema='ko'
```

**十分钟后，整台机器失联。**

---

## 1. 问题表现

最初的现象非常"像网络问题"：

```text
$ ssh worker1
kex_exchange_identification: Connection closed by remote host
Connection closed by x.x.x.x port 6000
```

TCP 能连上，但服务端一个字节的 SSH banner 都不返回就断开。同一时间，同一台跳板机上的 `worker2`（6001）却完全正常。

完整时间线（事后从 frps / journald / PG 日志拼出来）：

| 时间 | 事件 |
|---|---|
| 05-27 08:34 | 开机，**连续运行 5 个月** |
| 09:29:31 | PG 正常 checkpoint |
| ~09:30 | 执行 `python3 import_to_pg.py ...ko_poi_2026q3_release.csv` |
| **09:37:08** | frpc 断开，SSH 失联 |
| 09:43:14 | PG：`autovacuum worker took too long to start; canceled` |
| 09:44:32 | frpc 重连（**间隔 7 分 24 秒**） |
| 09:47:08 | PG：`unexpected EOF on client connection with an open transaction` |
| 09:50:01 | 现场执行 `sudo iotop -o`（已在查 I/O） |
| 09:55:14 | frpc 再次断开 |
| 09:59–10:14 | journald 反复报 `Under memory pressure, flushing caches` |
| 10:11–10:13 | SQL Server：`Long Sync IO > 1000ms` |
| **10:14:55** | 日志戛然而止，**无任何关机记录** |
| 10:17:50 | 现场强制断电重启，服务恢复 |

---

## 2. 排查过程

### 2.1 第一层：先证明"不是我的问题"

第一反应是怀疑本地网络 / 出口 IP / 密钥。这里踩了一个**很有价值的坑**：

```text
$ nc -vz x.x.x.x 6000   → succeeded!
$ nc -vz x.x.x.x 6999   → succeeded!   ← 这个端口根本不存在
$ nc -vz x.x.x.x 6998   → succeeded!   ← 也不存在
```

本地 macOS 开着 **Clash Verge 的 TUN 模式**（fake-ip 网段 `198.18.0.0/15`），它会在本机直接应答 TCP 握手再丢弃，导致**任何端口的连通性探测都返回"成功"**。

> 结论：排查内网/海外服务时，**不要用本机 `nc` 判断端口是否可达**。要么关掉 TUN，要么用一台第三方主机探测。

改用一台干净的 Linux 主机复测，结论立刻清晰：

```text
port 6000: REFUSED      ← 没有进程监听
port 6001: OPEN         ← worker2 正常
port 7000: OPEN         ← frps 控制端口正常
```

同一套密钥能登录 `worker2`，说明 **SSH 密钥、本地配置、出口 IP 全部没问题**。

### 2.2 第二层：frps 侧没有 6000 的监听

frp 的 TCP 端口是**动态创建**的——只有 frpc 注册 proxy 成功，frps 才会去 listen。查看跳板机：

```bash
ss -lntp | grep -E ':600[01]'
# *:6001  users:(("frps",...))    ← worker2 的
# （6000 没有）
```

再看 frps 日志，拿到了关键证据：

```text
2026-10-22 10:07:07 [I] client login info: ip [x.x.x.x] hostname [debian]
2026-10-26 09:37:08 [I] client exit success
2026-10-26 09:44:32 [I] client login info: ip [x.x.x.x] hostname [debian]
2026-10-26 09:55:14 [I] client exit success
```

**第一条推论（后来被证明是整案的关键）：**

`frpc.service` 配的是：

```ini
[Service]
Restart=always
RestartSec=5s
```

如果只是 frpc 崩溃或网络闪断，systemd **5 秒内**就会把它拉起来。但实际间隔是 **7 分 24 秒**。

> 这说明那 7 分钟里 **systemd 自己都跑不动**——不是服务挂了，是**整机卡死**。

### 2.3 第三层：整机还是单个服务？

三条独立证据同时指向"整机不在"：

1. Tailscale 节点 `100.x.x.x` 同时离线，`tailscale ping` 全部超时
2. 办公室出口公网 IP 的 22/80/443/7000 **全部被过滤**
3. 同一台跳板机上的 `worker2` 完全正常

**注意：frpc 和 Tailscale 是两条完全独立的通道（一条自建 frp，一条 DERP 中继）。两条同时消失，只能是它们共同的载体——那台机器——出了问题。**

### 2.4 第四层：机器恢复后的取证

现场强制断电重启后，机器回来了。此时立刻做只读取证：

```bash
journalctl --list-boots | tail -3
last -x | head -15
journalctl -b -1 --no-pager | tail -300
journalctl -b -1 -k | grep -iE "hung_task|blocked for more|I/O error|oom-kill|mce|thermal"
```

拿到的结论：

| 检查项 | 结果 | 含义 |
|---|---|---|
| `last -x shutdown` | **空** | 没有干净关机 → 硬断电/整机锁死 |
| 内核 `hung_task` | 无 | 不是磁盘 I/O 挂死 |
| 内核 `oom-kill` | **无** | 没有触发 OOM Killer |
| 内核 `MCE` / `panic` / `segfault` | 无 | 不是 CPU/内存硬件报错 |
| `nvme` / `ata` 错误 | 无 | 磁盘没有故障 |
| 上次 uptime | 5 个月 | 不是长期累积的老问题 |

但在这 40 分钟的窗口里，日志密度异常地高：

```text
09:59:13 systemd-journald[518]: Under memory pressure, flushing caches.
10:00:34 systemd-journald[518]: Under memory pressure, flushing caches.
10:00:50 tailscaled: subscriber for health.Change is slow (34.264196851s elapsed)
10:00:50 tailscaled: monitor: time jump detected (slept 24s), probably wake from sleep
10:00:46 pcp-pmie: Restart unresponsive PMDAs pmdaproc@debian pmdalinux@debian
10:11:25 sqlservr: Long Sync IO: Scheduler 7 had 2 Sync IOs longer than 1000 ms
10:14:55 systemd-journald[518]: Under memory pressure, flushing caches.   ← 最后一条
```

**关键读数：`subscriber is slow (34s elapsed)`。**

这是 tailscaled 内部的一个 goroutine 回调，正常应该在毫秒级完成。它花了 **34 秒**，意味着这个进程在 34 秒内根本没拿到 CPU 时间片。**整机陷入了严重的调度饥饿。**

同时 `systemd-journald` 反复打印 `Under memory pressure`——这是 systemd 收到 cgroup v2 PSI（Pressure Stall Information）内存压力事件后的反应。**内存压力是实锤。**

### 2.5 找到真凶

在现场遗留的 `~/.bash_history` 里找到了这条命令：

```bash
python3 import_to_pg.py /data/tools/ko_poi_2026q3_release.csv --schema='ko'
```

而脚本的核心只有两行：

```python
df = pd.read_csv(file_path, encoding=encoding)                      # 第 63 行
df.to_sql(table_name, engine, schema=schema, if_exists='replace',
          index=False, chunksize=10000)                             # 第 102 行
```

**`pd.read_csv()` 没有 `chunksize` 参数 —— 它会把整个文件一次性读进内存。**

再看文件规模：

```bash
$ ls -lh /data/tools/ko_poi_2026q3_release.csv
-rw-rw-r-- 1 blvh-worker blvh-worker 17G Oct 24 02:08 ko_poi_2026q3_release.csv

$ wc -l < /data/tools/ko_poi_2026q3_release.csv
18013371

$ head -1 ... | tr ',' '\n' | wc -l
194
```

**17 GB / 18,013,371 行 / 194 列。**

---

## 3. 根因分析

### 3.1 内存账：这是一道算术题

pandas 用 `object` dtype 存字符串，每个单元格的代价是：

```text
一个指针（8 字节） + 一个 Python 字符串对象（约 50~60 字节）

仅指针：  18,013,371 × 194 × 8B            ≈  28 GB
字符串：  非空单元格 × ~55B                 ≈  90~100 GB
────────────────────────────────────────────────────
实际需要：                                   ≈ 120 GB
```

而机器的实际预算是：

```text
物理内存 30 GB + Swap 31 GB = 61 GB
```

**差了整整一倍。这不是"可能爆"，是"必然爆"。**

### 3.2 为什么没有 OOM Killer？——Swap 抖动陷阱

这是整件事里最反直觉、也最值得记住的一点。

正常的 OOM 场景是：

```text
内存耗尽 → 内核 reclaim 失败 → OOM Killer 杀掉最占内存的进程 → 机器活着
```

但这次不一样，因为**有 31 GB swap**：

```text
内存耗尽 → 内核发现"还有 31GB swap 可用"
        → 不杀进程，改去换页
        → 换页量远超 swap 设备吞吐
        → 每次缺页都要等一次磁盘随机 I/O
        → CPU 全部时间耗在等待 I/O 上
        → 系统失去响应（thrashing）
```

这个状态在教科书里叫 **Thrashing（抖动）**：系统看起来很忙（高负载、高 I/O），实际吞吐趋近于零。

```text
$ free -h
               total   used   free   shared  buff/cache   available
Mem:            30Gi   6.0Gi  20Gi   293Mi       5.2Gi        24Gi
Swap:           31Gi     0B   31Gi
```

注意这是**重启后**的数据。事故发生时有 31GB swap 被疯狂换入换出，所以：

- 磁盘利用率 100% → SQL Server 报 `Long Sync IO > 1000ms`
- CPU 时间全在 iowait → tailscaled 34 秒拿不到调度
- 网络软中断饿死 → frpc / Tailscale / cloudflared 同时掉线
- 日志写入被拖慢 → 但 journald 仍在每 30 秒挤出一条 `Under memory pressure`

> **结论：31GB swap 在这里不是保险，是陷阱。它把"一个进程被 OOM 杀掉"升级成了"整台机器假死"。**

### 3.3 完整因果链

```text
pd.read_csv(17GB)
        │
        ├─→ 内存需求 120GB，物理 30GB
        │
        ├─→ 内核转向 swap（31GB，位于 NVMe）
        │        │
        │        ├─→ NVMe 随机 I/O 打满 → iowait 飙高
        │        │        └─→ SQL Server: Long Sync IO > 1000ms
        │        │        └─→ PG: autovacuum worker took too long to start
        │        │
        │        ├─→ CPU 调度饥饿 → tailscaled subscriber slow (34s)
        │        │
        │        └─→ 网络软中断饿死 → frpc / Tailscale / cloudflared 全线掉线
        │                 └─→ SSH 失联（kex_exchange_identification: closed）
        │
        └─→ 系统进入 Thrashing，持续 40 分钟无法自愈
                 └─→ 现场强制断电
```

### 3.4 磁盘不是原因

需要明确澄清：**这次不是磁盘故障。**

```text
内核日志中：
  ✗ 无 hung_task
  ✗ 无 ata / nvme / ext4 错误
  ✗ 无 I/O error
  ✗ 无 reset / timeout
```

磁盘只是**受害者**——被 swap 拖到 100% 忙碌。现场看到的"电源红灯"，几乎可以确定是**机箱前面板的硬盘活动指示灯**：两块盘（`/data` 上的 HDD 在读 17GB CSV，NVMe 上的 swap 在疯狂换页）都处于满负荷，指示灯常亮不闪，看起来就像报警。

**这也解释了为什么一断电重启就好了**——swap 清空、内存释放，一切恢复正常。如果是电源或主板真坏了，重启不可能这么干脆。

---

## 4. 三个让排查跑偏的陷阱

这次排查走了不少弯路，值得单独记下来。

### 陷阱一：本机 `nc` 的假阳性

Clash Verge 的 TUN 模式会在本机代理 TCP 握手，导致**所有端口探测都"成功"**。这会让排查方向直接跑偏到"服务端防火墙/白名单"。

> **正确做法**：用一台干净的第三方主机探测，或者临时关闭 TUN。

### 陷阱二：把"SSH 连不上"当成"SSH 的问题"

`kex_exchange_identification: Connection closed` 看起来像 sshd 配置或密钥问题，但真相是：

- frps 上根本没有 6000 的监听（因为 frpc 掉线了）
- 所以连接在 TCP 层就被关闭，**根本走不到认证阶段**

> **正确做法**：先看 `ss -lntp` 确认端口有没有监听，再谈认证。

### 陷阱三：把"红灯"当成"电源故障"

红灯 + 瞬间死亡，第一反应一定是电源坏了。但结合"重启即恢复"和"零内核错误"，更合理的解释是**硬盘活动灯常亮**。

> **正确做法**：区分"电源键指示灯"和"硬盘活动指示灯"，并观察风扇是否仍在转、按电源键是"一下关"还是"必须长按"。

---

## 5. 修复方案

### 5.1 重写导入脚本：全流式，内存恒定

旧实现的根本问题是**把文件大小当成了内存大小的下限**。新实现改为全程流式：

| 环节 | 旧实现 | 新实现 |
|---|---|---|
| CSV 读取 | `pd.read_csv()` 全量载入 | `csv.reader` 逐行迭代 |
| Excel 读取 | `pd.read_excel()` 全量载入 | `openpyxl(read_only=True)` 逐行迭代 |
| 写入方式 | `to_sql(chunksize=10000)` 逐批 INSERT | `COPY FROM STDIN`（`copy_expert`） |
| 内存占用 | 与文件大小成正比 | **与文件大小无关**，恒定几十 MB |
| 类型处理 | pandas 隐式推断 | 采样 2 万行显式推断，可 `--all-text` 关闭 |

核心代码结构：

```python
# 1) 行迭代器（生成器，不缓存整表）
header, rows = iter_csv_rows(path, encoding, delimiter, quotechar, has_header)

# 2) 采样推断类型（采样行回灌，不重复读文件）
sample = list(islice(rows, SAMPLE_ROWS))
types = infer_columns(sample, ncols, all_text=args.all_text)
rows = chain(sample, rows)

# 3) 用 COPY 协议流式写入
stream = ChunkStream(row_chunks(rows, ncols))
cur.copy_expert("COPY schema.tbl (...) FROM STDIN WITH (FORMAT csv, NULL '')", stream)
```

### 5.2 验证结果

用一份 273MB / 150 万行 / 20 列的数据实测：

```text
[完成] tmp_import_test.big
  行数   : 1,500,000
  表大小 : 316 MB
  耗时   : 7.0s  (215,615 行/秒)

[测量] 峰值内存 RSS = 68.1 MB
```

**峰值内存 68 MB，与文件大小无关。** 按同样吞吐推算，1800 万行约需 90 秒的 COPY 时间（实际瓶颈会落在从机械盘读取 17GB 上）。

功能验证覆盖：

- CSV（UTF-8 / GBK / BOM 自动探测）
- Excel（`.xlsx`，指定 sheet，中文列名）
- 含逗号、引号、换行的字段
- 空值 → NULL
- 类型推断：bigint / double precision / date / timestamp / boolean / text
- `--if-exists {replace,append,truncate,fail}`
- `--limit`（试跑）、`--dry-run`（只看建表语句）、`--all-text`（跳过推断）

### 5.3 运维护栏

代码修好只是第一步，还要有系统性防护：

**1）导入前关闭 swap**——让内核在内存爆时只杀那一个进程：

```bash
sudo swapoff -a
# 导入完成后再 sudo swapon -a
```

**2）给导入进程加内存上限**（双保险）：

```bash
systemd-run --scope -p MemoryMax=8G -p MemorySwapMax=2G \
  python3 import_to_pg.py big.csv --schema ko
```

**3）PG 参数回调**（30GB 机器跑 5 个容器，原配置偏激进）：

```ini
shared_buffers        = 8GB  → 4GB
maintenance_work_mem  = 4GB  → 2GB
max_wal_size          = 16GB → 8GB
```

**4）大文件导入规范**（写进团队 checklist）：

```text
文件 > 1GB   → 必须使用流式导入，禁止 pd.read_csv / pd.read_excel 全量读取
文件 > 10GB  → 必须使用 COPY，禁止 to_sql；导入前关 swap + 设内存上限
任何导入     → 先 --limit 100000 试跑，再全量
```

---

## 6. 涉及技术总结

| 技术 / 概念 | 作用与本次教训 |
|---|---|
| **`pd.read_csv()`** | 无 `chunksize` 时全量载入内存，内存占用可达文件大小的 5~10 倍 |
| **`DataFrame.to_sql()`** | 底层是逐批 INSERT，远慢于 COPY，且会产生海量 WAL |
| **PostgreSQL `COPY`** | 服务端批量导入协议，吞吐比 INSERT 高一个数量级，内存恒定 |
| **`openpyxl(read_only=True)`** | Excel 的流式读取模式，不把整张表加载进内存 |
| **Thrashing（抖动）** | 内存不足但仍有 swap 时，内核不杀进程而是疯狂换页，导致整机假死 |
| **Swap 的双面性** | 适量 swap 可防止偶发 OOM；过量 swap 会把"进程崩溃"升级成"整机雪崩" |
| **PSI（Pressure Stall Information）** | cgroup v2 的内存/IO 压力指标，`journald: Under memory pressure` 即来源于此 |
| **frp 动态端口** | TCP 端口由 frpc 注册后才创建，客户端掉线则监听消失 |
| **`Restart=always` + `RestartSec=5s`** | 可用作"整机是否卡死"的探针：服务未在预期时间内重启，说明 systemd 本身被饿死 |
| **`kex_exchange_identification`** | SSH 在密钥交换前被断开，说明问题在传输层，不在认证层 |
| **TUN 模式代理** | 会在本机伪造 TCP 握手，导致端口探测出现假阳性 |
| **`last -x` / `wtmp`** | 无 shutdown 记录 = 非正常关机（硬断电或整机锁死） |

---

## 7. 经验教训

### 7.1 这是同一类事故的第二次

翻仓库可以发现，2026 年 5 月已经写过一篇几乎同构的复盘：[记一次大数据量同步导致的 SQL Server 崩溃与全线服务掉线复盘](/post/sql-server-sync-crash-post-mortem/)。

那次是 **PostgreSQL → SQL Server** 的同步脚本，这次是 **CSV → PostgreSQL** 的导入脚本；那次用 `read_sql_query` + `to_sql`，这次用 `read_csv` + `to_sql`。

**同一个根因，换了个方向，又发生了一次。**

上次复盘里其实已经写下结论：

> 对于 10GB 以上的表，应优先考虑 `BCP` 或 `BULK INSERT`，而不是通过 Pandas 中转。

但这条结论**只停留在文档里，没有落到代码上**。`import_to_pg.py` 依然是 pandas 全量读取。

### 7.2 教训要变成机制，而不是文档

这次之后必须做到：

1. **危险 API 加拦截**：在公共工具库中封装 `safe_read_csv()`，超过阈值直接拒绝全量读取
2. **代码 review checklist**：出现 `read_csv` / `read_excel` / `to_sql` 必须说明数据规模
3. **默认参数要安全**：`import_to_pg.py` 默认就是流式，不存在"忘记加 chunksize"的可能
4. **先小后大**：任何导入先 `--limit 100000` 试跑

### 7.3 监控的缺失比故障本身更严重

从 09:37 失联到 10:17 恢复，**整整 40 分钟没有任何告警**。发现故障完全依赖"人想登录时登不上"。

必须补上：

- 外部探测 6000 端口（从独立机器，不经过本机代理）
- 内存 / swap / iowait 告警（`%iowait > 20%` 持续 1 分钟即告警）
- `frpc` 心跳超时告警

### 7.4 一台桌面机不该承担这个负载

需要正视的现实：

```text
Lenovo ThinkCentre K70-05（办公台式机）
├── i5-14500 / 30GB RAM
├── 同时跑 MSSQL + ClickHouse + PostGIS + Java(4G堆) + Nginx + Python
├── /data 是 5400 转 SMR 机械盘
└── 还挂着 WiFi（日志里全是扫描超时和 MAC 随机化）
```

这不是"配置调优"能解决的问题，是**硬件选型与业务负载不匹配**。中期应该：

- ETL 数据目录迁到 SSD（SMR 机械盘做批量写入是灾难）
- SQL Server 设置 `memory.memorylimitmb`
- Java 堆从 4GB 降到 2GB
- 关闭 WiFi，只用有线

---

## 8. 结语

这次故障的排查过程，本质上是一个**不断修正错误假设**的过程：

```text
"是不是我本地 IP 变了被白名单拦了？"   → 不是，回环也 refused
"是不是 SSH 配置/密钥坏了？"           → 不是，worker2 同密钥正常
"是不是磁盘坏了？"                     → 不是，内核零 I/O 错误
"是不是电源坏了？"                     → 不是，重启即恢复
"是不是 frpc 挂了？"                   → 不是，RestartSec=5s 却断了 7 分钟
                                            ↑ 这一条才是整案的转折点
```

**最有价值的一条线索，不是任何一个报错，而是一个"不符合预期的时间差"**：配置了 5 秒自动重启的服务，隔了 7 分 24 秒才回来。

当系统的行为与配置承诺不符时，说明故障发生在比配置更底层的地方。

而最讽刺的是：整台机器的崩塌，起因只是一行看起来很正常的 `pd.read_csv()`。
