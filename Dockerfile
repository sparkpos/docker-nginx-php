FROM alpine:3.7

ENV DRUSH_VERSION 8.1.15

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype \
    php7-memcached php7-redis mysql-client \
    php7-mbstring php7-gd nginx supervisor curl

###### install drush ######
RUN curl -fsSL -o /usr/local/bin/drush https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar | sh && \
chmod +x /usr/local/bin/drush && \
drush core-status 

##install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
		&& php composer-setup.php \
		&& php -r "unlink('composer-setup.php');" \
		&& mv composer.phar /usr/local/bin/composer

###### Chaning timezone ######
RUN set -x && \
    unlink /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

###### Config nginx ######
# RUN set -x && chown -R nginx:nginx /var/www/html

#Update nginx config
ADD nginx/nginx.conf /etc/nginx/
ADD nginx/sites/drupal7.conf /etc/nginx/sites-available/
RUN mkdir /etc/nginx/ssl
RUN set -x && chown -R nginx:nginx /etc/nginx

###### supervisord ######
ADD supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.ini

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nginx/ssl", "/etc/nignx/site-enabled", "/etc/php/7.1/php.d", "/var/www/phpext"]

EXPOSE 80 443
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.ini"]
