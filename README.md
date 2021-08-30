### Overview
Build nginx+php-fpm in one docker image, with predifined nginx config for Drupal, Laravel etc.

### Usage
```bash
### quick drupal running.
docker run -d -p 8080:80 -v /path-to-your-drupal-code:/var/www/html -e APP=drupal sparkpos/docker-nginx-php:7.1-alpine

### quick drupal running.
docker run -d -p 8080:80 -v /path-to-your-drupal-code:/var/www/html -e APP=drupal -e DRUPAL_WEB_ROOT=web sparkpos/docker-nginx-php:7.1-alpine


### quick laravel running.
docker run -d -p 8080:80 -v /path-to-your-laravel-code:/var/www/html -e APP=laravel sparkpos/docker-nginx-php:7.1-alpine
```

### docker-compose example
see [docker-compose.yml](https://github.com/sparkpos/docker-nginx-php/blob/master/docker-compose-example.yml)

### environment
#### General
|Name|Description|
|----|-----------|
|APP|the type of app, current allowed value: drupal, laravel|
|DRUPAL_WEB_ROOT|for drupal project that initialized via compose, the code is located in "web". using this flag to indicate.|
|MAX_FILE_UPLOAD_SIZE|Modify the upload file size, this will change both the nginx & php config. default value: 32M|

#### php & php-fpm
|Name|Desciption|
|----|----------|
|PHP_MEM_LIMIT|The php memory limit in php.ini. default value is 128M.|
|PHP_FPM_PM|modify the php-fpm processing type, allowed values: static, ondemand, dynamic|
|PHP_FPM_PM_MAX_CHILDREN|modify the pm.max_children for php-fpm config.|
|PHP_FPM_PM_PROCESS_IDLE_TIMEOUT|modify the pm.process_idle_timeout. this is availiable when pm = ondemand|
|PHP_FPM_PM_START_SERVERS|modify the pm.start_servers. this is availiable when pm = dynamic|
|PHP_FPM_PM_MIN_SPARE_SERVERS|modify the pm.min_spare_servers. this is availiable when pm = dynamic|
|PHP_FPM_PM_MAX_SPARE_SERVERS|modify the pm.max_spare_servers. this is availiable when pm = dynamic|
|PHP_FPM_STATUS_ENABLE|enable the fpm status path or not. the path is /status|
|TIMEOUT|modify the nginx.conf:proxy_read_timeout and php.ini:max_execution_time|

#### cron support
* provide default drupal cron, run weekly
* for custom cron command, using docker volumes for different perpose
```
/etc/periodic/min
/etc/periodic/15min
/etc/periodic/hourly
/etc/periodic/daily
/etc/periodic/weekly
/etc/periodic/monthly
```
