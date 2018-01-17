#!/bin/sh

#Add extension mongodb
cd /usr/share/  && \
curl -Lk https://pecl.php.net/get/mongodb-1.1.8.tgz | gunzip | tar x -C /usr/share/  && \
mv mongodb-1.1.8 mongodb && \
/usr/bin/phpize7.1  && \
./configure --with-php-config=/usr/bin/php-config7.1 && \
make && make install && \
touch /etc/php/7.1/mods-available/mongodb.ini && \
echo "extension=mongodb.so" >> /etc/php/7.1/mods-available/mongodb.ini && \
ln -sf /etc/php/7.1/mods-available/mongodb.ini /etc/php/7.1/fpm/conf.d/mongodb.ini
