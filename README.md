# platform proxy

English | [简体中文](./README_cn.md)

## Build And Run

### Compilation environment preparation

Please install the latest version of Docker.

### Source code download

You can download the entire project using the overall project download method, or you can download the repository of this module using the following command.

- Create a local directory , run cmd: `mkdir ./platform-proxy`
- Enter the directory, run cmd: `cd  ./platform-proxy`
- Run cmd: `git clone git@github.com:ao-space/platform-proxy.git .`

### Container image building

Run cmd: `docker build -t hub.eulix.xyz/ao-space/platform-proxy:dev .` , Where the tag parameter can be modified according to the actual situation.。

### Environment variables

- REDIS_ADDR: redis server addr
- REDIS_PORT: redis server port
- REDIS_PASSWORD: redis access password

### Deploy

Run cmd: `docker run -itd --name platform-proxy -p 8001:80  -e REDIS_ADDR=192.168.10.155  -e REDIS_PORT=19462  -e REDIS_PASSWORD=EV8RYxWgEdVTwuyL hub.eulix.xyz/ao-space/platform-proxy:dev`

## Contribution Guidelines

Contributions to this project are very welcome. Here are some guidelines and suggestions to help you get involved in the project.

[Contribution Guidelines](https://github.com/ao-space/ao.space/blob/dev/docs/en/contribution-guidelines.md)

## Contact us

- Email: <developer@ao.space>
- [Official Website](https://ao.space)
- [Discussion group](https://slack.ao.space)
