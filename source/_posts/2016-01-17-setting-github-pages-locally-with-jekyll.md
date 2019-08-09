---
layout: post
title: "本地部署Github-pages+Jekyll环境"
date: 2016-01-17 14:34
categories: jekyll
---
### First of all,安装[Ruby](https://www.ruby-lang.org/en/)
检查ruby是否安装
```
ruby --version
```
如果没有安装,先安装ruby version >= 2.x.x
```
apt-get install ruby ruby2.3-dev
```
```
gem install bundler
```
有依赖问题,解决依赖.
```
apt-get install ruby2.3-dev
```
安装
```
bundle install
```
启动服务
```
bundle exec jekyll serve
```
默认为http://localhost:4000。可指定host和port。
```
bundle exec jekyll serve --host=0.0.0.0 --port=1234
```

这样就可以安安心心地写markdown,而不用去费神其它不必要的锁事。

参考资料：
1.  [Using Jekyll with Pages](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/)
