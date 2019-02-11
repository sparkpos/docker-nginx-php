#!/usr/bin/env bash
APP=${APP:=drupal}
mv /tmp/$APP.conf /etc/nginx/site-enabled/

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
 sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEM_LIMIT}M/g" /usr/local/etc/php/php.ini
fi

# Increase the post_max_size
if [ ! -z "$MAX_FILE_UPLOAD_SIZE" ]; then
  sed -i "s/post_max_size = 32M/post_max_size = ${MAX_FILE_UPLOAD_SIZE}M/g" /usr/local/etc/php/php.ini
  sed -i "s/upload_max_filesize = 32M/upload_max_filesize= ${MAX_FILE_UPLOAD_SIZE}M/g" /usr/local/etc/php/php.ini
  sed -i "s/client_max_body_size 30M;/client_max_body_size ${MAX_FILE_UPLOAD_SIZE}M;/g" /etc/nginx/nginx.conf
fi

exec "$@"