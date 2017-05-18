# docker-lemp

Deploy LEMP(Linux+Nginx+MariaDB+PHP) using docker.

基于 `Ubuntu 16.04` 构建，使用 `docker-compose` 部署最新版的 `Nginx` + `MariaDB` + `PHP`

## 一、安装前准备

* [docker](https://docs.docker.com/installation)
* [docker compose](https://docs.docker.com/compose/install)

## 二、部署 LEMP

`vim docker-compose.yml`

### 2.1 docker-compose

```shell
version: '2'
services:
    mariadb:
        container_name: mariadb
        image: mariadb:latest
        ports:
            - "3306:3306"
        environment:
            - MYSQL_ROOT_PASSWORD=123456
        volumes:
            - /var/lib/mysql:/var/lib/mysql
        restart: always
    lemp:
        container_name: lemp
        image: idiswy/lemp:latest
        ports:
            - "80:80"
            - "443:443"
        links:
            - mariadb
        volumes:
            - /var/www/html:/var/www/html
        restart: always
```

参数说明：

- `MYSQL_ROOT_PASSWORD`: 将`123456`换成你的MySQL Root密码
- `volumes`: 挂载左边是宿主机路径，右边是容器里的路径

### 2.2 运行 docker-compose

```shell
docker-compose up -d
```

### 2.3 Nginx 站点配置

安装一个可以进入容器的小工具

```
curl --fail -L -O https://github.com/phusion/baseimage-docker/archive/master.tar.gz && \
tar xzf master.tar.gz && \
./baseimage-docker-master/install-tools.sh
```

进入容器，nginx 配置目录在 `/etc/nginx`

```
docker-bash lemp
```

## 三、docker compose 更多用法


```shell
docker-compose -h
```