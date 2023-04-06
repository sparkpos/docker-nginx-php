### Overview
Build nginx+php-fpm in one docker image, with predifined nginx config for Drupal, Laravel etc.

### Usage
```bash
### quick drupal running.
docker run -d -p 8080:80 -v /path-to-your-drupal-code:/var/www/html -e APP=drupal sparkpos/docker-nginx-php:7.4-alpine

### quick drupal running.
docker run -d -p 8080:80 -v /path-to-your-drupal-code:/var/www/html -e APP=drupal -e DRUPAL_WEB_ROOT=web sparkpos/docker-nginx-php:7.4-alpine

### quick laravel running.
docker run -d -p 8080:80 -v /path-to-your-laravel-code:/var/www/html -e APP=laravel sparkpos/docker-nginx-php:7.4-alpine
```

### docker-compose example
see [docker-compose.yml](https://github.com/sparkpos/docker-nginx-php/blob/master/docker-compose-example.yml)

### environment
#### General
|Name|Description|
|----|-----------|
|APP|the type of app, current allowed value: drupal, laravel|
|DRUPAL_WEB_ROOT|for drupal project that initialized via compose, the code is located in "web". using this flag to indicate.|
|HTTP_HEADER_X_FRAME_OPTIONS|X-Frame-Options, default value: SAMEORIGIN; see [here](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/X-Frame-Options)|
|HTTP_HEADER_X_CONTENT_SECURITY_POLICY|Content-Security-Policy, default value: "default-src 'self';";see [here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)|
|MAX_FILE_UPLOAD_SIZE|Modify the upload file size, this will change both the nginx & php config. default value: 32M|

#### php & php-fpm
|Name|Desciption|Default Value|
|----|----------|---|
|NGINX_WORKER_PROCESSES|nginx worker_processes, allowed value: auto, 1, 2, 3 ...｜auto|
|PHP_MEM_LIMIT|The php memory limit in php.ini. |1024M|
|PHP_FPM_PM|modify the php-fpm processing type, allowed values: static, ondemand, dynamic|dynamic|
|PHP_FPM_PM_MAX_CHILDREN|modify the pm.max_children for php-fpm config.|30|
|PHP_FPM_PM_PROCESS_IDLE_TIMEOUT|modify the pm.process_idle_timeout. this is availiable when pm = ondemand|10s|
|PHP_FPM_PM_START_SERVERS|modify the pm.start_servers. this is availiable when pm = dynamic|10|
|PHP_FPM_PM_MIN_SPARE_SERVERS|modify the pm.min_spare_servers. this is availiable when pm = dynamic|5|
|PHP_FPM_PM_MAX_SPARE_SERVERS|modify the pm.max_spare_servers. this is availiable when pm = dynamic|10|
|PHP_FPM_STATUS_ENABLE|enable the fpm status path or not. the path is /status|
|TIMEOUT|modify the nginx.conf:proxy_read_timeout and php.ini:max_execution_time|30|

#### cron support
* provide default drupal cron, run daily.
* for custom cron command, using docker volumes for different perpose
* check [here](https://github.com/sparkpos/docker-nginx-php/blob/master/conf/crontab-root) for more details.
```
/etc/periodic/min
/etc/periodic/15min
/etc/periodic/hourly
/etc/periodic/daily
/etc/periodic/weekly
/etc/periodic/monthly
```
