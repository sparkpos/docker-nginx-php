FROM php:7.3-fpm-alpine

ENV DRUSH_VERSION 8.4.8
ENV DRUSH_LAUCHER 0.9.1
ENV COLUMNS 0
ENV DRUSH_LAUNCHER_FALLBACK=/usr/local/bin/drush8
ENV PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[00m\]@\h: \[\033[01;36m\]\w\[\033[00m\] \[\t\]\n\$ '

###### Install packages
RUN apk add --no-cache --virtual .build-deps g++ gcc make autoconf curl curl-dev bzip2 bzip2-dev \
    zip libzip-dev icu icu-libs icu-dev libmemcached libmemcached-dev zlib-dev cyrus-sasl-dev \
    mysql-client nginx supervisor tzdata bash libpng-dev freetype-dev libwebp-dev libjpeg-turbo-dev libmcrypt-dev \
    git imagemagick-dev libtool postgresql-libs postgresql-dev ffmpeg && \
    ln -s /usr/bin/ffmpeg /usr/local/bin/ffmpeg && \
    ln -s /usr/bin/ffprobe /usr/local/bin/ffprobe && \
    docker-php-ext-configure gd --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/  \
        --with-webp-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
    ##### Install memcached and redis packages
    echo no | pecl install redis && \
    echo yes | pecl install memcached && \
    echo yes | pecl install imagick && \
    echo yes | pecl install xdebug && \
    docker-php-ext-enable redis memcached xdebug imagick && \
    ##### Install php extension packages
    docker-php-ext-install mysqli opcache gd bz2 zip intl pdo_mysql bcmath pgsql pdo_pgsql calendar && \
    ###### set up timezone
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    ###### install drush ######
    curl -fsSL -o /usr/local/bin/drush8 https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar | sh && \
    chmod +x /usr/local/bin/drush8 && \
    drush8 core-status && \
    ###### install drush laucher ######
    wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/$DRUSH_LAUCHER/drush.phar && \
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush && \
    ##install composer
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

###### change php.ini ######
ADD conf/php.ini /usr/local/etc/php/
ADD conf/www.conf /usr/local/etc/php-fpm.d/www.conf
ADD conf/nginx.conf /etc/nginx/
ADD conf/drupal8.conf /tmp/drupal.conf
ADD conf/laravel.conf /tmp/laravel.conf
ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN sed -i -e "s/listen = 9000//g" /usr/local/etc/php-fpm.d/zz-docker.conf && \
    sed -i -e "s/access.log = \/proc\/self\/fd\/2/access.log = \/proc\/self\/fd\/1/g" /usr/local/etc/php-fpm.d/docker.conf && \
    chmod +x /usr/local/bin/docker-entrypoint && \
    mkdir -p /etc/nginx/ssl /etc/nginx/site-enabled /etc/supervisor/conf.d

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nignx/site-enabled"]

ENTRYPOINT ["docker-entrypoint"]

EXPOSE 80
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
