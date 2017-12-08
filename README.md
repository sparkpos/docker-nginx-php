Nginx and PHP for Docker

## Last Version
nginx: **1.12.1**   
php:   **7.1.12**

## Docker Hub   
**Nginx-PHP7:** [https://hub.docker.com/r/sparkpos/docker-nginx-php/](https://hub.docker.com/r/sparkpos/docker-nginx-php/)   
   
## Installation
Pull the image from the docker index rather than downloading the git repo. This prevents you having to build the image on every docker host.

```
docker pull sparkpos/docker-nginx-php:latest
```

To pull the New Relic Version:   
```
docker pull sparkpos/docker-nginx-php:newrelic
```

## Running
### To simply run the container:


nginx+php

```
docker run -itd --name lnmp -p 8080:80 sparkpos/docker-nginx-php:latest
```

nginx+php+newrelic

```
docker run -itd --name lnmp -p 8080:80  -e NEWRELICAPPNAME=testing -e NEWRELICKEY=8322790a22222fa25822188520d8fc3 sparkpos/docker-nginx-php:newrelic

```
You can then browse to http://\<docker_host\>:8080 to view the default install files.



## Volumes
If you want to link to your web site directory on the docker host to the container run:
```sh
docker run --name lnmp -p 8080:80 -v /your_code_directory:/var/www/html -d skiychan/nginx-php7
```


## Enabling Extensions With *.so
Add xxx.ini to folder ```/your_php_extension_ini``` and add xxx.so to folder ```/your_php_extension_file```, then run the command:   
```sh
docker run --name nginx \
-p 8080:80 -d \
-v /your_php_extension_ini:/usr/local/php/etc/php.d \
-v /your_php_extension_file:/data/phpext \
skiychan/nginx-php7
```
in xxx.ini, "zend_extension = /data/phpext/xxx.so", the zend_extension must be use ```/data/phpext/```.   

## Enabling Extensions With Source
Also, You can add the source to ```extension.sh```. Example:   
```
#Add extension memcached
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


You can see the **[wiki](https://github.com/skiy-dockerfile/nginx-php7/wiki/Question-&-Answer)** for more information

## Thanks
* [https://hub.docker.com/r/skiychan/nginx-php7](https://hub.docker.com/r/skiychan/nginx-php7)
* [https://www.karelbemelmans.com/2017/08/docker-php-container-with-new-relic/](https://www.karelbemelmans.com/2017/08/docker-php-container-with-new-relic/)

