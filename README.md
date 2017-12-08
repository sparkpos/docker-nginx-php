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
docker run --name lnmp -p 8080:80 -v /your_code_directory:/var/www/html -d sparkpos/docker-nginx-php:latest
```

