FROM php:fpm-alpine3.7

ENV DRUSH_VERSION 8.1.15
ENV DRUSH_LAUCHER 0.5.1

###### Install packages
RUN apk --no-cache add g++ gcc make autoconf curl curl-dev bzip2 bzip2-dev zip icu icu-libs icu-dev \
    libmemcached libmemcached-dev zlib-dev cyrus-sasl-dev mysql-client nginx supervisor tzdata bash

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
RUN curl -fsSL -o /usr/local/bin/drush8 https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar | sh && \
    chmod +x /usr/local/bin/drush8 && \
    drush8 core-status 

###### install drush laucher ######
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/$DRUSH_LAUCHER/drush.phar && \
    chmod +x drush.phar && \
    mv drush.phar /usr/local/bin/drush
ENV DRUSH_LAUNCHER_FALLBACK=/usr/local/bin/drush8

##install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

### php:fpm-alpine3.7 default user www-data uid 82
###### change php.ini ######
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/php.ini /usr/local/etc/
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/www.conf /etc/php7/php-fpm.d/www.conf

##### update curl cacert ######
## see https://stackoverflow.com/questions/24611640/curl-60-ssl-certificate-unable-to-get-local-issuer-certificate
#ADD https://curl.haxx.se/ca/cacert.pem /var/certs/curl_cacert.pem
#RUN echo "curl.cainfo=\"/var/certs/curl_cacert.pem\"" >> /etc/php7/conf.d/00_curl.ini

#Update nginx config
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/nginx.conf /etc/nginx/
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/drupal8.conf /etc/nginx/site-enabled/
RUN mkdir /etc/nginx/ssl

###### supervisord ######
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/supervisord.conf /etc/supervisord.conf

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nignx/site-enabled", "/usr/local/etc"]

EXPOSE 80 443
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
