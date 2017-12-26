FROM alpine:3.7

ENV DRUSH_VERSION 8.1.15

###### Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-opcache php7-common php7-mcrypt php7-json php7-openssl php7-curl \
    php7-bz2 php7-zip php7-dev php7-zlib php7-xml php7-simplexml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-pdo php7-pdo_mysql php7-bcmath\
    php7-memcached php7-redis mysql-client \
    php7-mbstring php7-gd php7-tokenizer nginx supervisor curl

###### set up timezone
RUN apk update && apk add ca-certificates && \
    apk add tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

###### install drush ######
RUN curl -fsSL -o /usr/local/bin/drush https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar | sh && \
    chmod +x /usr/local/bin/drush && \
    drush core-status 

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
RUN set -x && \
    sed -i 's/memory_limit = .*/memory_limit = 1024M/' /etc/php7/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 32M/' /etc/php7/php.ini && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 32M/' /etc/php7/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 32M/' /etc/php7/php.ini && \
    sed -i 's/^; max_input_vars =.*/max_input_vars =10000/' /etc/php7/php.ini && \
    sed -i 's/^;cgi.fix_pathinfo=.*/cgi.fix_pathinfo = 0;/' /etc/php7/php.ini

#Update nginx config
ADD nginx/nginx.conf /etc/nginx/
ADD nginx/sites/drupal7.conf /etc/nginx/sites-available/
RUN mkdir /etc/nginx/ssl && \
    rm /etc/nginx/conf.d/default.conf && \
    chown -R nginx:nginx /etc/nginx

###### supervisord ######
ADD supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nignx/site-enabled", "/etc/php7/php.d"]

EXPOSE 80 443
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
