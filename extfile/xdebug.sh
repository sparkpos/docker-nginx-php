#!/bin/sh

#Add extension xdebug
cd /usr/share/  && \
curl -Lk https://github.com/xdebug/xdebug/archive/XDEBUG_2_4_0RC3.tar.gz | gunzip | tar x -C /usr/share/  && \
mv xdebug-XDEBUG_2_4_0RC3 xdebug && cd xdebug  && \
/usr/bin/phpize7.1  && \
./configure --with-php-config=/usr/bin/php-config7.1 && \
make && make install && \
touch /etc/php/7.1/mods-available/xdebug.ini && \
echo "extension=xdebug.so" >> /etc/php/7.1/mods-available/xdebug.ini && \
ln -sf /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/fpm/conf.d/xdebug.ini
