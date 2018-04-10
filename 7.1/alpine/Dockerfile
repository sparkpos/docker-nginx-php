FROM alpine:3.7

ENV DRUSH_VERSION 8.1.15
ENV DRUSH_LAUCHER 0.5.1
ENV NEWRELIC_VERSION 8.0.0.204

##add www-data user for nginx and php
# RUN set -x && \
#     addgroup -g 82 -S www-data && \
#     adduser -u 82 -D -S -G www-data www-data 

###### Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-opcache php7-common php7-mcrypt php7-json php7-openssl php7-curl \
    php7-bz2 php7-zip php7-dev php7-zlib php7-xml php7-simplexml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter php7-ctype php7-pdo php7-pdo_mysql php7-bcmath\
    php7-memcached php7-redis php7-pgsql php7-pdo_pgsql php7-mbstring php7-gd php7-tokenizer php7-simplexml php7-calendar mysql-client nginx supervisor curl bash

###### set up timezone
RUN apk update && apk add ca-certificates && \
    apk add tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

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

###### Chaning timezone ######
RUN set -x && \
    unlink /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

###### change php.ini ######
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/php.ini /etc/php7/
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/www.conf /etc/php7/php-fpm.d/www.conf

##### update curl cacert ######
## see https://stackoverflow.com/questions/24611640/curl-60-ssl-certificate-unable-to-get-local-issuer-certificate
#ADD https://curl.haxx.se/ca/cacert.pem /var/certs/curl_cacert.pem
#RUN echo "curl.cainfo=\"/var/certs/curl_cacert.pem\"" >> /etc/php7/conf.d/00_curl.ini

#####Update nginx config
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/nginx.conf /etc/nginx/
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/drupal8.conf /tmp/drupal.conf
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/laravel.conf /tmp/laravel.conf
RUN mkdir /etc/nginx/ssl /etc/nginx/site-enabled

###### supervisord ######
ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/supervisord.conf /etc/supervisord.conf

###### startup prepare ######
VOLUME ["/var/www/html"]

EXPOSE 80 443
WORKDIR /var/www/html

ADD https://raw.githubusercontent.com/sparkpos/nginx-php-config/master/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
