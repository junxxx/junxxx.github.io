---
title: "记一次 Certbot 证书自动续签失效与 Derper 崩溃循环的排查复盘"
date: 2026-06-30T16:45:00+08:00
draft: false
tags: ["Certbot", "SSL", "Docker", "Nginx", "Crontab", "Tailscale", "DERP", "SRE"]
categories: ["Ops", "Infra"]
---

## 0. 背景

在 AWS Lightsail 上运行着一台 Debian 服务器（以下简称 `laws`），承载了两个关键服务：

- **derper.paisen.site** — 自建的 Tailscale DERP 中继节点，运行在 Docker 容器（`fredliang/derper`）中
- **bridge.paisen.site** — 另一个业务服务，由 Nginx 托管

证书由 Certbot + Let's Encrypt 签发，并通过 `cp` 命令复制到 Docker 挂载目录 `/etc/derp-certs/`。

某天发现 `https://derper.paisen.site` 显示不安全，Tailscale 客户端无法正常使用自建 DERP 节点，开始排查。

---

## 1. 问题表现

- 浏览器访问 `https://derper.paisen.site` 提示证书错误
- `docker ps` 显示 derper 容器处于 `Restarting (1)` 崩溃循环
- 原有的 crontab 定时任务理论上应该每月 1 日自动续签并更新证书

---

## 2. 原始 Crontab 设计缺陷

查看原始 crontab：

```cron
# 00:00 执行证书续签
0 0 1 * * /usr/bin/certbot renew --force-renewal

# 00:30 复制证书到 Docker 目录并重启容器
30 0 1 * * cp /etc/letsencrypt/live/derper.paisen.site/fullchain.pem /etc/derp-certs/derper.paisen.site.crt \
  && cp /etc/letsencrypt/live/derper.paisen.site/privkey.pem /etc/derp-certs/derper.paisen.site.key \
  && docker restart derper
```

**根本缺陷：竞态条件（Race Condition）**

两个 cron job 完全独立运行，第二条在 00:30 执行时，**无法感知第一条是否已成功完成**。若 certbot 续签耗时超过 30 分钟，或续签失败，`cp` 命令照样执行——复制的是过期或损坏的证书。

此外，两个 job 之间没有任何错误处理或日志输出，出现问题时完全无法溯源。

---

## 3. 排查过程

### 3.1 确认证书文件状态

```bash
# 检查 letsencrypt live 目录的证书有效期
sudo openssl x509 -in /etc/letsencrypt/live/derper.paisen.site/fullchain.pem -noout -dates

# 检查 Docker 挂载目录中的证书有效期
sudo openssl x509 -in /etc/derp-certs/derper.paisen.site.crt -noout -dates

# 对比两个文件是否一致
sudo diff /etc/letsencrypt/live/derper.paisen.site/fullchain.pem /etc/derp-certs/derper.paisen.site.crt
```

发现 Docker 目录中的 `.crt` 和 `live/` 下的证书不同——这是因为 `--force-renewal` 当天触发了**两次**（手动调试时多执行了一次），产生了两个不同的证书。

### 3.2 分析 Derper 崩溃日志

```bash
docker logs derper --tail 20
```

```text
derper: can not start cert provider: can not load x509 key pair for hostname
"derper.paisen.site": tls: private key does not match public key
```

**问题清晰**：`/etc/derp-certs/` 下的 `.crt` 和 `.key` 来自不同的续签批次，公钥与私钥不匹配，TLS 握手无法建立。

这是因为 `live/` 目录下使用的是**软链接**，指向 `/etc/letsencrypt/archive/` 中的实际文件。两次 `--force-renewal` 后，symlink 更新指向最新版本（`cert4.pem`, `privkey4.pem`），但此前 `cp` 只复制了部分文件，导致 `.crt` 和 `.key` 来自不同的版本。

### 3.3 发现 bridge.paisen.site 的独立问题

在执行 `certbot renew --dry-run` 验证时，发现第二个证书也在续签失败：

```text
Failed to renew certificate bridge.paisen.site with error: Could not bind TCP port 80
because it is already in use by another process on this system (such as a web server).
```

检查端口占用：

```bash
sudo ss -tlnp | grep ':80 '
```

```text
LISTEN  nginx  pid=669188
```

原来 `bridge.paisen.site` 的 certbot 配置使用的是 `standalone` 认证器——certbot 会自己在 80 端口起一个临时 HTTP 服务来完成 ACME 挑战，但 Nginx 已经占用了 80 端口，导致绑定失败。

查看续签配置：

```bash
sudo cat /etc/letsencrypt/renewal/bridge.paisen.site.conf | grep authenticator
# authenticator = standalone   ← 问题所在
```

---

## 4. 修复方案

### 4.1 使用 Certbot Deploy Hook（核心修复）

Certbot 提供了官方的 hook 机制：将脚本放在 `/etc/letsencrypt/renewal-hooks/deploy/` 目录下，certbot 会在**每次续签成功后**自动执行这些脚本。

这彻底解决了竞态问题——复制和重启操作**只在续签真正成功时**才会发生。

```bash
sudo tee /etc/letsencrypt/renewal-hooks/deploy/copy-to-derper.sh << 'EOF'
#!/bin/bash
set -e
cp /etc/letsencrypt/live/derper.paisen.site/fullchain.pem /etc/derp-certs/derper.paisen.site.crt
cp /etc/letsencrypt/live/derper.paisen.site/privkey.pem /etc/derp-certs/derper.paisen.site.key
docker restart derper
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cert copied and derper restarted successfully" >> /var/log/certbot-renew.log
EOF

sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/copy-to-derper.sh
```

**脚本中 `set -e` 的作用**：任何一步失败（cp 失败、docker 重启失败）都会立即退出，不会执行后续操作，避免半成功状态。

### 4.2 简化 Crontab

将原来两条有竞态的 job 合并为一条，并加上日志输出：

```cron
# 修复前（两条独立 job，有竞态）
0  0 1 * * /usr/bin/certbot renew --force-renewal
30 0 1 * * cp ... && cp ... && docker restart derper

# 修复后（一条 job，deploy hook 接管后续动作）
0 0 1 * * /usr/bin/certbot renew --force-renewal >> /var/log/certbot-renew.log 2>&1
```

### 4.3 修复 bridge.paisen.site 的认证器

将 `standalone` 改为 `nginx`，让 certbot 借助已运行的 Nginx 完成 ACME 挑战，无需占用 80 端口：

```bash
sudo sed -i 's/authenticator = standalone/authenticator = nginx/' \
  /etc/letsencrypt/renewal/bridge.paisen.site.conf
```

### 4.4 手动同步当前证书（应急修复）

由于当天 force-renewal 跑了两次导致 `.crt` 和 `.key` 版本不一致，需要手动重新对齐：

```bash
sudo cp /etc/letsencrypt/live/derper.paisen.site/fullchain.pem /etc/derp-certs/derper.paisen.site.crt
sudo cp /etc/letsencrypt/live/derper.paisen.site/privkey.pem /etc/derp-certs/derper.paisen.site.key
docker restart derper
```

验证公钥一致性：

```bash
# 两者输出的 md5 应完全相同
sudo openssl x509 -in /etc/derp-certs/derper.paisen.site.crt -noout -pubkey | md5sum
sudo openssl pkey -in /etc/derp-certs/derper.paisen.site.key -pubout | md5sum
```

---

## 5. 验证结果

### Dry-run 全部通过

```bash
sudo certbot renew --dry-run
```

```text
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/bridge.paisen.site/fullchain.pem (success)
  /etc/letsencrypt/live/derper.paisen.site/fullchain.pem (success)
```

### 外部 TLS 验证

```bash
echo | openssl s_client -connect derper.paisen.site:443 -servername derper.paisen.site 2>/dev/null \
  | openssl x509 -noout -dates -subject
```

```text
notBefore=Jun 30 07:04:03 2026 GMT
notAfter =Sep 28 07:04:02 2026 GMT
subject  =CN=derper.paisen.site
```

证书有效，Derper 容器稳定运行。

---

## 6. 涉及技术总结

| 技术 | 作用 |
|---|---|
| **Let's Encrypt / Certbot** | 免费 TLS 证书签发与自动续签 |
| **Certbot Deploy Hook** | 续签成功后自动触发的脚本钩子，官方推荐的后处理方式 |
| **ACME HTTP-01 Challenge** | Let's Encrypt 验证域名所有权的方式，需要 80 端口可达 |
| **Certbot authenticator: nginx** | 借用已运行的 Nginx 完成 ACME 挑战，无需独占 80 端口 |
| **Certbot authenticator: standalone** | Certbot 自行监听 80 端口，与 Nginx 冲突 |
| **TLS 公私钥匹配** | `.crt`（公钥证书）与 `.key`（私钥）必须来自同一次签发，否则 TLS 握手失败 |
| **Docker 挂载与证书更新** | 使用 `cp` 而非软链接时，需要主动同步文件，容器内看不到宿主机 symlink 的更新 |
| **Crontab 竞态条件** | 多个独立 job 之间无依赖关系，时序无法保证，应用 `&&` 或外部 hook 串联 |
| **Tailscale DERP** | Tailscale 的中继协议，用于穿透 NAT，自建节点需要有效的 TLS 证书 |

---

## 7. 经验教训

1. **不要用两条独立 cron job 模拟依赖关系**。应该用 `&&` 串联，或使用工具原生提供的 hook 机制（如 certbot 的 `deploy-hooks`）。

2. **`cp` 复制证书要保证原子性**——cert 和 key 必须同一时刻从同一来源复制，分两步复制在并发场景下有风险。

3. **`--force-renewal` 慎用**。Let's Encrypt 有速率限制（每个域名每周最多 5 次），手动调试时反复执行容易产生多个版本的证书，引发版本混乱。正常情况下使用 `certbot renew`（只在距到期 30 天内才实际续签）即可。

4. **certbot authenticator 要与实际服务栈匹配**。有 Nginx 就用 `nginx`，有 Apache 就用 `apache`，没有 Web 服务才考虑 `standalone`。
