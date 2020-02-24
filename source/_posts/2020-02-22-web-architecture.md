---
title: web-architecture
date: 2020-02-22 14:56:16
tags:
---
# 架构模型
- 服务注册
- 服务发现
- API网关
- 服务通迅
- 数据处理
- 应用安全
- 测试
- 部署
- 运维

# Web架构模型

## SOA(Service-Oriented Architecture)

## Microservice Architecture
微服务主要解决的问题是如何快速地开发和部署我们的服务。  
微服务与传统架构的不同之处在于，微服务的每个服务与其数据库都是独立的，可以无依赖地进行部署。

### 微服务的理解

致力松耦合，高内聚  
基于互联网构建系统  
更依赖基础设施的自动化--持续集成&持续部署  
相比于整体架构，微服务的服务不可靠性更需要考虑。 由于服务可能随时故障，快速检测故障乃至自动恢复变更非常重要。

参考资料:

1. [整体架构VS微服务架构](https://martinfowler.com/articles/microservices.html)
1. [AWS微服务](https://aws.amazon.com/cn/microservices/)