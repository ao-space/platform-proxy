# platform proxy

[English](README.md) | 简体中文

## 构建和部署

### 构建环境准备

请安装最新版本的 docker 。

### 源码下载

可以通过整体项目源码下载的方式，或通过以下方式：

- 创建本地目录，执行命令: `mkdir ./platform-proxy`
- 进入本地目录，执行命令: `cd ./platform-proxy`
- 下载源码，执行命令: `git clone git@github.com:ao-space/platform-proxy.git .`

### 镜像构建

执行命令: `docker build -t hub.eulix.xyz/ao-space/platform-proxy:dev .` , tag 参数可以根据实际情况修改。

### 环境变量

- REDIS_ADDR: redis 服务器地址
- REDIS_PORT: redis 服务器端口
- REDIS_PASSWORD: redis 访问密码

### 部署服务

执行命令: `docker run -itd --name platform-proxy -p 8001:80  -e REDIS_ADDR=192.168.10.155  -e REDIS_PORT=19462  -e REDIS_PASSWORD=EV8RYxWgEdVTwuyL hub.eulix.xyz/ao-space/platform-proxy:dev`

## 贡献指南

我们非常欢迎对本项目进行贡献。以下是一些指导原则和建议，希望能够帮助您参与到项目中来。

[贡献指南](https://github.com/ao-space/ao.space/blob/dev/docs/cn/contribution-guidelines.md)

## 联系我们

- 邮箱：<developer@ao.space>
- [官方网站](https://ao.space)
- [讨论组](https://slack.ao.space)
