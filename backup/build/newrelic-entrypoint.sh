#!/usr/bin/env bash

export NR_INSTALL_SILENT=true
sed -i "s/newrelic.appname = .*/newrelic.appname = \"$NEWRELICAPPNAME\"/" /etc/php/7.1/fpm/conf.d/newrelic.ini
sed -i "s/newrelic.license = .*/newrelic.license = \"$NEWRELICKEY\"/" /etc/php/7.1/fpm/conf.d/newrelic.ini

exec "$@"
