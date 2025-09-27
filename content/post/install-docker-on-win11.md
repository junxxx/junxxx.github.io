---
title: "Install Docker on Win11"
date: 2025-09-27T09:30:04+08:00
draft: true
categories: ["Tech", "Life", "Thought"]
tags: [""]
author: "Paisen"
---

# 在全新 Windows 11 系统上安装并运行 Docker Desktop —— 踩坑与解决方案

## 背景

我最近在一台新装的 **Windows 11 专业版 (24H2)** 系统上尝试安装 **Docker Desktop**。
这是一台 AMD Ryzen 平台的电脑，BIOS 已经开启了虚拟化（SVM/AMD-V），系统安装时也使用了 **默认设置**。

在全新安装的 Win11 环境里，我遇到了一个看似简单却非常棘手的问题：
**Docker Desktop 始终提示系统不支持虚拟化。**

---

## 问题表现

### 1. Docker Desktop 报错

安装完成后启动时提示：

```
Virtualization support not detected
Docker Desktop requires virtualization support to run.
```

### 2. Hyper-V 检查结果

在 PowerShell 中运行：

```powershell
Get-ComputerInfo | Select-Object HyperV*
```

结果显示：

```
HyperVisorPresent : False
HyperVRequirementDataExecutionPreventionAvailable : True
HyperVRequirementSecondLevelAddressTranslation    : True
HyperVRequirementVirtualizationFirmwareEnabled    : True
HyperVRequirementVMMonitorModeExtensions          : True
```

👉 硬件、BIOS 都支持虚拟化，但 **Hyper-V 没跑起来**。

### 3. WSL2 状态

`wsl --status` 显示默认版本是 2，但尝试安装发行版时报错：

```
HCS_E_HYPERV_NOT_INSTALLED
```

### 4. 系统信息 (msinfo32)

* BIOS 模式：UEFI ✅
* 虚拟化：已启用 ✅
* VBS 状态：已启用，但未运行 ❌

---

## 排查过程

1. **检查 Windows 功能**
   在 “启用或关闭 Windows 功能” 中，确认已勾选：

   * Hyper-V → 平台
   * 虚拟机平台 (Virtual Machine Platform)
   * 适用于 Linux 的 Windows 子系统 (WSL)

   多次确认无误。


2. **检查服务**

   * Hyper-V 主机服务、虚拟机管理服务都设置为自动并已启动。
   * 依然无效。

3. **尝试关闭安全功能**
   在 Windows 安全中心关闭“内存完整性/核心隔离”，无改善。

4. **最终解决方案**
   在 GitHub issue 中找到类似案例。

   * 进入 BIOS，发现 **NX Mode (No eXecute bit)** 默认是关闭的。
   * 将其改为 **Enabled**。
   * 保存重启后，`HyperVisorPresent=True`，Hyper-V 成功加载。
   * 这时 WSL2 和 Docker Desktop 都能正常运行。

---

## 结果

* **WSL2** 可以正常安装并运行 Linux 发行版。
* **Docker Desktop** 成功启动，并能拉取镜像、运行容器。

---

## 总结与经验

1. 在 Win11 上运行 Docker Desktop，必须满足：

   * BIOS 开启 **SVM/AMD-V 或 Intel VT-x**
   * BIOS 开启 **NX (No eXecute) / XD (eXecute Disable) / DEP**
   * Windows 以 **UEFI + GPT 模式** 安装
   * 打开以下 Windows 功能：

     * Hyper-V 平台
     * 虚拟机平台
     * WSL2

2. 常见误区：

   * 只开启了虚拟化 (SVM/VT-x)，但忽略了 NX/DEP。
   * Windows 功能里只勾了 Hyper-V，没有勾“虚拟机平台”。
   * 看到 VBS 显示“已启用但未运行”，却没意识到本质原因是 Hyper-V 根本没启动。

3. 关键修复点：

   * **必须在 BIOS 里启用 CPU 的 NX Mode (No eXecute)**
   * 这是 Hyper-V/WSL2 的硬性前提，否则 Windows 再怎么设置都无效。

---

## BIOS 必须开启的选项清单

* **AMD 平台**

  * SVM Mode (Secure Virtual Machine)
  * AMD-V
  * NX Mode (No eXecute Bit)

---

✅ 经过以上调整，最终 Docker Desktop 在全新安装的 Windows 11 上顺利运行。
之前就听说在windows系统里安装Docker会非常麻烦，没想到这次也消耗了我大半天时间。
这次经历也提醒我：**在虚拟化问题排查中，别忘了检查 BIOS 里的 NX/DEP 设置**。

---


## Reference
1. []()