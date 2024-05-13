---
title: "Build Python Dev Env With Docker"
date: 2019-03-12T16:04:49+08:00
draft: true
categories: ["Tech", "Tools"]
tags: ["Docker"]
author: "Paisen"
---
Dockerfile
```
FROM python:3
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

RUN pip install -r requirements.txt
CMD [ "/bin/bash", "-c" ]
```


## Reference
1. []()