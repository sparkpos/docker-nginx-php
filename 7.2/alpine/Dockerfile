FROM php:fpm-alpine3.7

ENV DRUSH_VERSION 8.1.15

###### Install packages
RUN apk --no-cache add g++ gcc make autoconf curl curl-dev bzip2 bzip2-dev zip icu icu-libs icu-dev && \
    libmemcached libmemcached-dev zlib-dev cyrus-sasl-dev mysql-client nginx supervisor tzdata 

##### Install memcached and redis packages
RUN echo no | pecl install redis && \
    echo yes | pecl install memcached && \
    docker-php-ext-enable redis memcached

##### Install php extension packages
RUN docker-php-ext-install mysqli opcache  bz2 zip intl  pdo_mysql bcmath

###### set up timezone
RUN rm /etc/localtime && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

###### install drush ######
RUN curl -fsSL -o /usr/local/bin/drush https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar | sh && \
    chmod +x /usr/local/bin/drush && \
    drush core-status 

##install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

### php:fpm-alpine3.7 default user www-data uid 82
###### change php.ini ######
ADD config/php.ini /usr/local/etc/
ADD config/www.conf /etc/php7/php-fpm.d/www.conf

#Update nginx config
ADD config/nginx.conf /etc/nginx/
ADD config/drupal8.conf /etc/nginx/site-enabled/
RUN mkdir /etc/nginx/ssl

###### supervisord ######
ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nignx/site-enabled", "/usr/local/etc"]

EXPOSE 80 443
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
