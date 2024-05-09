---
title: "Deploy Hugo on Github Page"
date: 2022-05-09T22:11:32+08:00
draft: false
categories: ["Tech", "Life", "Thought"]
tags: [""]
author: "Paisen"
---
[Hugo](https://gohugo.io/) is a framework witten with Golang for building website.

I told my wife I wrote something on blog. After heard that, she said she wants to build a blog and start writing. So I spent a few hours on setting up the a local hugo site and deployed it on Github pages.

Here are all the thing you need:
- A [github](https://github.com/) account, if you didn't have one, you need to sign up
- [Git](https://git-scm.com/) installed on your local machine
- [Install hugo](https://gohugo.io/installation/)
- Head over to GitHub and create a new public repository named username.github.io, where username is your username (or organization name) on GitHub
- Generate a website on local machine
- Push your local reposity to github
- Add a github workflow
- Config reposity's page setting

If everything goes well, you will see your blog online https://YourGithubUsername.github.io/


If you encounter a 404 error after deploying your website on github pages, your can adjust the workflows in Action or change the setting of page of the reposity.


## Reference
1. [Quickstart for GitHub Pages](https://docs.github.com/en/pages/quickstart)
1. [GitHub Pages](https://pages.github.com/)
1. [Host on GitHub Pages](https://gohugo.io/hosting-and-deployment/hosting-on-github/)
