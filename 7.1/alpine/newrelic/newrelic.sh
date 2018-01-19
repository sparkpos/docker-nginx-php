#!/bin/sh

if [ ! -z ${NEWRELIC_KEY} ]; 
then 
  if [ ! -z ${NEWRELIC_APPNAME} ];
  then
    sed -i "s/newrelic.license =.*/newrelic.license = ${NEWRELIC_KEY}/g" /etc/php7/conf.d/newrelic.ini 
    sed -i "s/newrelic.appname =.*/newrelic.appname = ${NEWRELIC_APPNAME}/g" /etc/php7/conf.d/newrelic.ini  
  fi
fi


