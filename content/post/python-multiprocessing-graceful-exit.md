---
title: "Python 多进程优雅退出的实践：以腾讯地图 API 批量检测为例"
date: 2026-05-19T13:01:17+08:00
draft: false
categories: ["Tech"]
tags: ["Python", "Multiprocessing", "PostgreSQL", "API"]
author: "Paisen"
---

在处理大规模数据异步请求时，Python 的 `multiprocessing.Pool` 是我们常用的工具。然而，当任务涉及到外部 API 配额限制或需要保持数据库状态一致性时，简单的进程池往往力不从心。

本文将通过一个腾讯地图 POI 在线检测脚本的优化过程，分享如何实现多进程的“优雅退出”与“任务恢复”。

## 1. 面临的问题

原始脚本在处理任务时存在两个痛点：

1. **退出太暴力**：当某个子进程检测到 API 配额耗尽（状态码 121）时，直接调用 `sys.exit(0)`。这只会导致当前子进程退出，其他子进程仍会继续无效请求，且主进程无法感知到全局任务已停止。
2. **状态不一致**：正在处理的批次（Batch）被标记为 `doing`，如果此时因为配额问题强行终止，这些记录会一直停留在 `doing` 状态，下次运行脚本时无法自动重试。

## 2. 解决方案：跨进程信号量

为了让所有进程能够协同工作，我们需要一个“全局开关”。

### 2.1 使用 Manager().Event()
在主进程中创建一个共享的 `Event` 对象，并将其传递给每个 worker 进程。

```python
from multiprocessing import Pool, Manager

def run():
    # ... 初始化 ...
    with Manager() as manager:
        stop_event = manager.Event()
        tasks = [(i, dsn, chunk, stop_event) for i, chunk in enumerate(chunks)]
        
        with Pool(processes=workers) as pool:
            pool.starmap(worker_main, tasks)
```

### 2.2 信号的触发与监听
在 Worker 进程的循环中，我们需要在处理新批次前检查信号：

```python
def worker_main(worker_id, dsn, poi_ids, stop_event):
    for i in range(0, len(poi_ids), BATCH_SIZE):
        if stop_event.is_set():
            logger.info("检测到停止信号，优雅退出...")
            break
        # 处理业务逻辑...
```

## 3. 任务恢复：状态回滚

当触发退出信号时，我们不仅要停下来，还要处理好手头的任务。

### 3.1 定义回滚操作
我们添加了 `mark_todo` 函数，将正在处理的批次状态从 `doing` 重置为 `todo`。

```python
def mark_todo(conn, poi_ids):
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE processing.tx_poi_online_check SET status='todo', updated=NOW() WHERE poi_tx_id = ANY(%s)",
            (poi_ids,),
        )
    conn.commit()
```

### 3.2 在异常处执行
当遇到 `API_QUOTA_ERROR` (121) 时，先重置当前批次，再广播停止信号。

```python
if api_status == API_QUOTA_ERROR:
    log.error("API 额度已耗尽，重置当前批次并请求退出")
    mark_todo(conn, batch)
    stop_event.set()
    return
```

## 4. 总结

通过 `Manager().Event()`，我们实现了跨进程的通信，使得局部的 API 错误能够演化为全局的优雅停机。配合数据库的状态回滚逻辑，确保了脚本在下一次运行时能够无缝衔接，大大提高了系统的健壮性。

在工程实践中，**优雅退出（Graceful Exit）**往往比**高性能执行**更重要，因为它决定了系统的运维成本和数据可靠性。
