---
layout: post
title: "Git server"
date: 2018-12-05 
categories: git
---
## 自建git server并实现自动部署
git支持的几种协议

通过钩子可以实现，提交代码之后自动更新线上代码
git仓库里的hooks目录，cp post-update.sample post-update,编辑post-update
```
#!/bin/sh
unset GIT_DIR
projectDir=/opt/case/note
if [ ! -d $projectDir ]
then
  echo 'no such file no directory'
  exit
fi
cd $projectDir
if [ ! -d $projectDir/.git ]
then
  su - nginx -s /bin/shell -c "git init && git remote add origin /opt/data/git/note.git"
fi
su - nginx -s /bin/shell -c "git clean -df && git pull origin master"
```

遇到的问题：
linux账号权限问题

解决方案：


参考资料：
1. [set git server](https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server)
1. [git hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
