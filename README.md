# docker-lemp

Deploy LEMP(Linux+Nginx+MariaDB+PHP) using docker.

基于 `Ubuntu 16.04` 构建，使用 `docker-compose` 部署最新版的 `Nginx` + `MariaDB` + `PHP`

## 一、安装前准备

* [docker](https://docs.docker.com/installation)
* [docker compose](https://docs.docker.com/compose/install)

```shell
curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## 二、部署 LEMP

### 2.1 不使用 docker-compose

1.Mariadb

```shell
docker run --name mariadb \
-v /var/lib/mysql:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123456 \
-p 3306:3306 \
-d mariadb:latest
```

2.lemp

```shell
docker run \
--restart=always \
--name lemp \
--link mariadb:mysql \
-p 80:80 \
-p 443:443 \
-v /var/www/public:/var/www/public \
-d idiswy/lemp:latest
```

3.phpmyadmin

```shell
docker run --name phpmyadmin \
--link mariadb:mysql \
-p 8080:80 \
-d idiswy/phpmyadmin:latest
```

### 2.2 使用 docker-compose

`vim docker-compose.yml`

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
            - /var/www/html:/var/www/public
        restart: always
```

参数说明：

- `MYSQL_ROOT_PASSWORD`: 将`123456`换成你的MySQL Root密码
- `volumes`: 挂载左边是宿主机路径，右边是容器里的路径

### 2.3 运行 docker-compose

```shell
docker-compose up -d
```

### 2.4 Nginx 站点配置

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