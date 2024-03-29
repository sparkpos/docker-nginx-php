#!/usr/bin/env bash
APP=${APP:=drupal}
if [ -f /tmp/"$APP".conf ]; then
  mv /tmp/$APP.conf /etc/nginx/site-enabled/
fi
HTTP_HEADER_X_FRAME_OPTIONS=${HTTP_HEADER_X_FRAME_OPTIONS:="SAMEORIGIN"};
sed -i "s/add_header X-Frame-Options SAMEORIGIN;/add_header X-Frame-Options $HTTP_HEADER_X_FRAME_OPTIONS;/g" /etc/nginx/site-enabled/*.conf


if [ "${HTTP_HEADER_X_CONTENT_SECURITY_POLICY_ENABLE}" = "TRUE" ]; then
  ## using default value that in Dockerfile.
  ## HTTP_HEADER_X_CONTENT_SECURITY_POLICY=${HTTP_HEADER_X_CONTENT_SECURITY_POLICY:="default-src 'self';"};
  sed -i "s#add_header Content-Security-Policy \"default-src 'self';\";#add_header Content-Security-Policy \"$HTTP_HEADER_X_CONTENT_SECURITY_POLICY\";#g" /etc/nginx/site-enabled/*.conf
else
  sed -i '/add_header Content-Security-Policy/d' /etc/nginx/site-enabled/*.conf
fi

# https://www.php.net/manual/en/ini.core.php#ini.variables-order
sed -i "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" /usr/local/etc/php/php.ini

# if the drupal is init by composer, the code directory locate on "web".
# This options is used to change the nginx root path.
## DRUPAL_SUBDIR support.
if [ ! -z "$DRUPAL_SUBDIR" ]; then
  DRUPAL_SUBDIR=${DRUPAL_SUBDIR:=fake-subdir-placeholder}
  sed -i "s/fake-subdir-placeholder/$DRUPAL_SUBDIR/g" /etc/nginx/site-enabled/drupal.conf
fi
## DRUPAL8_WEB_DIR depreacated.
if [ ! -z "$DRUPAL8_WEB_DIR" ]; then
  DRUPAL8_WEB_DIR=${DRUPAL8_WEB_DIR:=web}
  sed -i "s/root \/var\/www\/html;/root \/var\/www\/html\/$DRUPAL8_WEB_DIR;/g" /etc/nginx/site-enabled/drupal.conf
fi
if [ ! -z "$DRUPAL_WEB_ROOT" ]; then
  DRUPAL8_WEB_DIR=${DRUPAL_WEB_ROOT:=web}
  sed -i "s/root \/var\/www\/html;/root \/var\/www\/html\/$DRUPAL_WEB_ROOT;/g" /etc/nginx/site-enabled/drupal.conf
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
  sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEM_LIMIT}M/g" /usr/local/etc/php/php.ini
fi
# Increase the timeout
if [ ! -z "$NGINX_WORKER_PROCESSES" ]; then
  sed -i "s/worker_processes auto;/worker_processes ${NGINX_WORKER_PROCESSES};/g" /etc/nginx/nginx.conf
fi
# Increase the timeout
if [ ! -z "$TIMEOUT" ]; then
  sed -i "s/max_execution_time = 30/max_execution_time = ${TIMEOUT}/g" /usr/local/etc/php/php.ini
  sed -i "s/proxy_read_timeout 60;/proxy_read_timeout ${TIMEOUT};/g" /etc/nginx/nginx.conf
  sed -i "s/fastcgi_read_timeout 60;/fastcgi_read_timeout ${TIMEOUT};/g" /etc/nginx/nginx.conf
fi

# Increase the post_max_size
if [ ! -z "$MAX_FILE_UPLOAD_SIZE" ]; then
  sed -i "s/post_max_size = 32M/post_max_size = ${MAX_FILE_UPLOAD_SIZE}/g" /usr/local/etc/php/php.ini
  sed -i "s/upload_max_filesize = 32M/upload_max_filesize= ${MAX_FILE_UPLOAD_SIZE}/g" /usr/local/etc/php/php.ini
  sed -i "s/client_max_body_size 32M;/client_max_body_size ${MAX_FILE_UPLOAD_SIZE};/g" /etc/nginx/nginx.conf
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

# Enable xdebug
XdebugFile='/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini'
if [[ "$ENABLE_XDEBUG" == "1" ]] ; then
  if [ -f $XdebugFile ]; then
	sleep 1
  else
  	echo "Enabling xdebug"
  	echo "If you get this error, you can safely ignore it: /usr/local/bin/docker-php-ext-enable: line 83: nm: not found"
  	# see https://github.com/docker-library/php/pull/420
    # see if file exists
    if [ -f $XdebugFile ]; then
        # See if file contains xdebug text.
        if grep -q xdebug.remote_enable "$XdebugFile"; then
            echo "Xdebug already enabled... skipping"
        else
            XDEBUG_IDEKEY=${XDEBUG_IDEKEY:=PHPSTORM}
            echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > $XdebugFile # Note, single arrow to overwrite file.
            echo "xdebug.remote_enable=1 "  >> $XdebugFile
            echo "xdebug.remote_host=127.0.0.1" >> $XdebugFile
            echo "xdebug.remote_port=9001" >> $XdebugFile
            echo "xdebug.remote_connect_back=1" >> $XdebugFile
            echo "xdebug.remote_autostart=1" >> $XdebugFile
            # echo "xdebug.remote_log=/tmp/xdebug.log"  >> $XdebugFile
            echo "xdebug.idekey=${XDEBUG_IDEKEY}"  >> $XdebugFile
        fi
    fi
  fi
else
    if [ -f $XdebugFile ]; then
        # echo "Disabling Xdebug"
	sleep 1
        rm $XdebugFile
    fi
fi

# fpm status enable flag.
if [ ! -z "$PHP_FPM_STATUS_ENABLE" ]; then
  sed -i "s/;pm.status_path = \/status/pm.status_path = \/status/g" /usr/local/etc/php-fpm.d/www.conf
fi
exec "$@"
