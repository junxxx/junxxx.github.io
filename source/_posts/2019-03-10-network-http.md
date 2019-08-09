---
layout: post
title: "HTTP协议"
date: 2019-03-10 
categories: network
---
HTTP(HyperText Transfer Protocol)是无连接，无状态的，是面向文本的。

Web服务器有一个服务进程，监听着TCP端口。一旦监听到连接建立并建立了TCP连接之后，浏览器就向服务器发出浏览某个页面的请求，服务器接着就返回所请求的页面作为响应。最后释放TCP连接。

HTTP有两类报文：
1. 请求报文  
    method URL version CRLF  
    header-field: value  
    entity body  
1. 响应报文  
    version status short   description    
    header-field: value   
    entity body

状态码都是三位数字的，分为5大类共33种：  
1xx 表示通知信息的，如请求收到了或正在进行处理。  
2xx 表示成功，如接受或知道了。  
3xx 表示重定向，如要完成请求还必须采取进一步的行动。   
4xx 表示客户的差错，如请求中有错误的语法或不能完成。  
5xx 表示服务器的差错，如服务器失效无法完成请求。  
