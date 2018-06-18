#!/usr/bin/env bash
APP=${APP:=drupal}
mv /tmp/$APP.conf /etc/nginx/site-enabled/
exec "$@"
