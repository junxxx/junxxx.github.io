---
layout: post
title: "Laravel Modern PHP Framework"
date: 2016-03-19 19:00
categories: PHP Framework
---
[Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-macos)是PHP包管理工具，借用Composer管理我们项目中的依赖包非常方便。
这次，我们选用Composer的方式安装Laravel。
## Install [Laravel](http://laravel.com/) on Ubuntu 14.04
Create project via composer:
```
composer create-project --prefer-dist laravel/laravel projectName
```

生产环境安装Nginx，PHP。配置文件要注意进程用户，各文件夹的权限也要注意。
### todo list
[] 如何引入静态资源
[] trait如何使用


参考资料：
1. [生产环境部署Laravel项目](https://laraveldaily.com/how-to-deploy-laravel-projects-to-live-server-the-ultimate-guide/)
1. [多版本PHP-FPM管理](http://php.net/manual/en/install.fpm.php) 

