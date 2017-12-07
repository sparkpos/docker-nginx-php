FROM phusion/baseimage
# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV HOME /root
CMD ["/sbin/my_init"]

# Nginx-PHP Installation
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim unzip curl wget  mysql-client-5.7 build-essential python-software-properties
RUN add-apt-repository -y ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx git
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes \
    php7.1-mysql \
    php7.1-xml \
    php7.1-gd \
    php7.1-json \
    php7.1-curl \
    php7.1-mbstring \
    php7.1-opcache \
    php7.1-bz2 \
    php7.1-fpm \
    php7.1-common \
    php7.1-mcrypt \
    php7.1-dev \
    php7.1-xml \
    php7.1-bcmath \
    php7.1-soap \
    php7.1-pgsql

###### Install php-fpm extension######
### Enable memcache
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y pkg-config zlib1g-dev re2c libmemcached-dev supervisor
RUN set -x && \
    cd /usr/share/ && \
    wget https://github.com/php-memcached-dev/php-memcached/archive/php7.zip && \
    unzip php7.zip && rm php7.zip && \
    cd php-memcached-php7 && \
    /usr/bin/phpize7.1 && \
    ./configure --with-php-config=/usr/bin/php-config7.1 && \
    make && \
    make install && \
    touch /etc/php/7.1/mods-available/memcached.ini && \
    echo "extension=memcached.so" >> /etc/php/7.1/mods-available/memcached.ini && \
    ln -sf /etc/php/7.1/mods-available/memcached.ini /etc/php/7.1/fpm/conf.d/memcached.ini

### Enable redis
RUN set -x && \
    cd /usr/share/ && \
    wget https://github.com/phpredis/phpredis/archive/3.1.4.zip -O phpredis.zip && \
    unzip phpredis.zip && rm phpredis.zip && \
    mv phpredis-* phpredis && cd phpredis && \
    /usr/bin/phpize7.1  && \
    ./configure --with-php-config=/usr/bin/php-config7.1 && \
    make && \
    make install && \
    touch /etc/php/7.1/mods-available/redis.ini && \
    echo "extension=redis.so" >> /etc/php/7.1/mods-available/redis.ini && \
    ln -sf /etc/php/7.1/mods-available/redis.ini /etc/php/7.1/fpm/conf.d/redis.ini

### add php other extension
ADD extfile/ /var/www/phpext/
RUN chmod a+x /var/www/phpext/*

###### change php.ini ######
RUN set -x && \
    sed -i 's/memory_limit = .*/memory_limit = 1024M/' /etc/php/7.1/fpm/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 32M/' /etc/php/7.1/fpm/php.ini && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 32M/' /etc/php/7.1/fpm/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 32M/' /etc/php/7.1/fpm/php.ini && \
    sed -i 's/^; max_input_vars =.*/max_input_vars =10000/' /etc/php/7.1/fpm/php.ini && \
    sed -i 's/^;cgi.fix_pathinfo=.*/cgi.fix_pathinfo = 0;/' /etc/php/7.1/fpm/php.ini

###### install drush ######
RUN set -x && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require drush/drush:~8
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN sed -i '1i export PATH="$HOME/.composer/vendor/drush/drush:$PATH"' $HOME/.bashrc && \
    source $HOME/.bashrc

###### Chaning timezone ######
RUN set -x && \
    unlink /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

###### cinfig nginx ######
RUN set -x && \
    chown -R www-data:www-data /var/www/html
#Update nginx config
ADD nginx.conf /etc/nginx/
ADD index.php /var/www/html
RUN rm /etc/nginx/sites-enabled/default && \
    mkdir /etc/nginx/ssl

###### Insert supervisord conf file ######
ADD supervisord.conf /etc/

###### Start shell #######
ADD startup.sh /var/www/startup.sh
RUN chmod +x /var/www/startup.sh

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nginx/ssl", "/etc/nignx/site-enabled", "/etc/php/7.1/php.d", "/var/www/phpext"]
EXPOSE 80 443
WORKDIR /var/www/html
ENTRYPOINT ["/var/www/startup.sh"]
