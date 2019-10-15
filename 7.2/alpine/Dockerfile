FROM php:7.2-fpm-alpine

ENV DRUSH_VERSION 8.3.0
ENV DRUSH_LAUCHER 0.6.0
ENV COLUMNS 0
ENV DRUSH_LAUNCHER_FALLBACK=/usr/local/bin/drush8

###### Install packages
RUN apk --no-cache add g++ gcc make autoconf curl curl-dev bzip2 bzip2-dev zip icu icu-libs icu-dev \
    libmemcached libmemcached-dev zlib-dev cyrus-sasl-dev mysql-client nginx supervisor tzdata bash \
    libpng-dev freetype-dev libjpeg-turbo-dev libmcrypt-dev git imagemagick-dev libtool\
    postgresql-libs postgresql-dev && \
    docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
##### Install memcached and redis packages
    echo no | pecl install redis && \
    echo yes | pecl install memcached && \
    echo yes | pecl install imagick && \
    docker-php-ext-enable redis memcached imagick && \
##### Install php extension packages
    docker-php-ext-install mysqli opcache gd bz2 zip intl pdo_mysql bcmath pgsql pdo_pgsql calendar && \
###### set up timezone
    rm /etc/localtime && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

###### install drush ######
RUN curl -fsSL -o /usr/local/bin/drush8 https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar | sh && \
    chmod +x /usr/local/bin/drush8 && \
    drush8 core-status && \
##### drush lancher ######
    wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/$DRUSH_LAUCHER/drush.phar && \
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush && \
##### install composer #####
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
## install drupal console ###
    curl https://drupalconsole.com/installer -L -o drupal.phar && \
    mv drupal.phar /usr/local/bin/drupal && \
    chmod +x /usr/local/bin/drupal

###### change php.ini ######
ADD https://raw.githubusercontent.com/sparkpos/docker-nginx-php/master/conf/php.ini /usr/local/etc/php/
RUN sed -i -e "s/listen = 9000//g" /usr/local/etc/php-fpm.d/zz-docker.conf
RUN sed -i -e "s/access.log = \/proc\/self\/fd\/2/access.log = \/proc\/self\/fd\/1/g" /usr/local/etc/php-fpm.d/docker.conf
ADD https://raw.githubusercontent.com/sparkpos/docker-nginx-php/master/conf/www.conf /usr/local/etc/php-fpm.d/www.conf

#Update nginx config
ADD https://raw.githubusercontent.com/sparkpos/docker-nginx-php/master/conf/nginx.conf /etc/nginx/
ADD https://raw.githubusercontent.com/sparkpos/docker-nginx-php/master/conf/drupal8.conf /tmp/drupal.conf
ADD https://raw.githubusercontent.com/sparkpos/docker-nginx-php/master/conf/laravel.conf /tmp/laravel.conf
RUN mkdir /etc/nginx/ssl /etc/nginx/site-enabled

###### supervisord ######
ADD https://raw.githubusercontent.com/sparkpos/docker-nginx-php/master/conf/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /etc/supervisor/conf.d

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nignx/site-enabled", "/usr/local/etc"]

ADD https://raw.githubusercontent.com/sparkpos/docker-nginx-php/master/conf/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

EXPOSE 80
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
