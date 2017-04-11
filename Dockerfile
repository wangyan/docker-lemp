FROM phusion/baseimage:0.9.19
MAINTAINER WangYan <i@wangyan.org>

# Setup Nginx
RUN set -xe && \
    curl -O "http://nginx.org/keys/nginx_signing.key" && \
    apt-key add nginx_signing.key && \
    rm -f nginx_signing.key && \
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends --no-install-suggests -y \
            ca-certificates nginx && \
    # Forward logs to docker log collector
    # ln -sf /dev/stdout /var/log/nginx/access.log
    # ln -sf /dev/stderr /var/log/nginx/error.log

    # Nginx config
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak && \
    mkdir -p /etc/nginx/sites-enabled /var/www/html && \

    # Nginx Runit
    mkdir -p /etc/service/nginx && \
    echo '#!/bin/sh' >> /etc/service/nginx/run && \
    echo 'exec 2>&1' >> /etc/service/nginx/run && \
    echo 'exec nginx -g "daemon off;"' >> /etc/service/nginx/run && \
    chmod +x /etc/service/nginx/run

    COPY nginx/nginx.conf /etc/nginx/nginx.conf
    COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Setup PHP7
ENV TIMEZONE            Asia/Shanghai
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          128M
ENV PHP_MAX_FILE_UPLOAD 25
ENV PHP_MAX_POST        256M
ENV MAX_INPUT_VARS      5000

RUN set -xe && \
    apt-get install --no-install-recommends --no-install-suggests -y \
    php7.0-bcmath \
    php7.0-bz2 \
    php7.0-curl \
    php7.0-fpm \
    php7.0-gd \
    php7.0-gmp \
    php7.0-imap  \
    php7.0-json \
    php7.0-ldap \
    php7.0-mysql \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-pgsql \
    php7.0-sqlite3 \
    php7.0-xml \
    php7.0-xmlrpc \
    php7.0-xsl \
    php7.0-zip && \

    # PHP7 Config
    cp /etc/php/7.0/fpm/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf.bak && \
    cp /etc/php/7.0/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf.bak && \
    cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak && \

    sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i "s|pm.max_children =.*|pm.max_children = 12|i" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s|pm.start_servers =.*|pm.start_servers = 6|i" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s|pm.min_spare_servers =.*|pm.min_spare_servers = 2|i" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s|pm.max_spare_servers =.*|pm.max_spare_servers = 10|i" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php/7.0/fpm/php.ini && \
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php/7.0/fpm/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php/7.0/fpm/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php/7.0/fpm/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php/7.0/fpm/php.ini && \
    sed -i "s|;\s*max_input_vars =.*|max_input_vars = ${MAX_INPUT_VARS}|i" /etc/php/7.0/fpm/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php/7.0/fpm/php.ini && \

    # Runit Config
    mkdir -p /etc/service/phpfpm mkdir -p /run/php && \
    echo '#!/bin/sh' >> /etc/service/phpfpm/run && \
    echo 'exec 2>&1' >> /etc/service/phpfpm/run && \
    echo 'exec /usr/sbin/php-fpm7.0' >> /etc/service/phpfpm/run && \
    chmod +x /etc/service/phpfpm/run && \

    # APT Clean
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

VOLUME ["/var/www/html"]

EXPOSE 80 443

CMD ["/sbin/my_init"]