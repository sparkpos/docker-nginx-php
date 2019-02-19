#!/usr/bin/env bash
APP=${APP:=drupal}
if [ -f /tmp/"$APP".conf ]; then
  mv /tmp/$APP.conf /etc/nginx/site-enabled/
fi
# if the drupal is init by composer, the code directory locate on "web".
# This options is used to change the nginx root path.
if [ ! -z "$DRUPAL8_WEB_DIR" ]; then
  sed -i "s/root \/var\/www\/html;/root \/var\/www\/html\/web;/g" /etc/nginx/site-enabled/drupal.conf
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
  sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEM_LIMIT}M/g" /usr/local/etc/php/php.ini
fi

# Increase the post_max_size
if [ ! -z "$MAX_FILE_UPLOAD_SIZE" ]; then
  sed -i "s/post_max_size = 32M/post_max_size = ${MAX_FILE_UPLOAD_SIZE}M/g" /usr/local/etc/php/php.ini
  sed -i "s/upload_max_filesize = 32M/upload_max_filesize= ${MAX_FILE_UPLOAD_SIZE}M/g" /usr/local/etc/php/php.ini
  sed -i "s/client_max_body_size 32M;/client_max_body_size ${MAX_FILE_UPLOAD_SIZE}M;/g" /etc/nginx/nginx.conf
fi

# php-fpm process related config.
if [ ! -z "$PHP_FPM_PM" ]; then
  sed -i -E "s/pm = .*$/pm = ${PHP_FPM_PM}/g" /usr/local/etc/php-fpm.d/www.conf
  # dynamic/ondemand/static三种，都会用到pm.max_children这个配置。
  if [ ! -z "$PHP_FPM_PM_MAX_CHILDREN" ]; then
    sed -i -E "s/pm\.max_children = \d+$/pm.max_children = ${PHP_FPM_PM_MAX_CHILDREN}/g" /usr/local/etc/php-fpm.d/www.conf
  fi
  
  case $PHP_FPM_PM in
    ondemand)
      sed -i -E "s/;?pm.process_idle_timeout = .*/pm.process_idle_timeout = ${PHP_FPM_PM_PROCESS_IDLE_TIMEOUT}s/g" /usr/local/etc/php-fpm.d/www.conf;;
    dynamic)
      sed -i \
        -E "s/pm.start_servers = \d+/pm.start_servers = ${PHP_FPM_PM_START_SERVERS}/g;
        s/pm.min_spare_servers = \d+/pm.min_spare_servers = ${PHP_FPM_PM_MIN_SPARE_SERVERS}/g;
        s/pm.max_spare_servers = \d+/pm.max_spare_servers = ${PHP_FPM_PM_MAX_SPARE_SERVERS}/g" \
        /usr/local/etc/php-fpm.d/www.conf;;
  esac
fi

# fpm status enable flag.
if [ ! -z "$PHP_FPM_STATUS_ENABLE" ]; then
  sed -i "s/;pm.status_path = \/status/pm.status_path = \/status/g" /usr/local/etc/php-fpm.d/www.conf
fi

exec "$@"
