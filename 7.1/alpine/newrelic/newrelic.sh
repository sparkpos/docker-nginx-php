#!/bin/sh

if [ ! -z ${NEWRELIC_KEY} ]; 
then 
  if [ ! -z ${NEWRELIC_APPNAME} ];
  then
    
    sed -i \
        -e "s/newrelic.license =.*/newrelic.license = \${NEWRELIC_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \${NEWRELIC_APPNAME}/" \
        /etc/php7/conf.d/newrelic.ini
  fi
fi


