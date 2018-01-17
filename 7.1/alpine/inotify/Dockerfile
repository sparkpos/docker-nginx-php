FROM sparkpos/docker-nginx-php:7.1-alpine
RUN apk --no-cache add php7-calendar php7-pgsql php7-pdo_pgsql inotify-tools
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
