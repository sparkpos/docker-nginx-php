#!/bin/bash
### https://blog.dockbit.com/templating-your-dockerfile-like-a-boss-2a84a67d28e9
render() {
sedStr="
  s!%%PHP_VERSION%%!$version!g;
"

sed -r "$sedStr" $1
}

versions=(7.1 7.2 7.3 7.4 8.0 8.1-rc)
for version in ${versions[*]}; do
  if [ ! -d ${version}/alpine ]; then
    mkdir -p ${version}/alpine
  fi
  render Dockerfile-alpine.template > $version/alpine/Dockerfile
  # https://github.com/flyve-mdm/docker-environment/issues/68
  if [ "${version}" = "7.1" ]; then
    sed -i "s/pecl install xdebug/pecl install xdebug-2.9.0/g" ${version}/alpine/Dockerfile
  fi
  # https://www.php.net/manual/en/image.installation.php
  # php 7.4 gd config differenct as before.
  if [[ "${version}" = "7.4" || "${version}" = "8.0" || "${version}" = "8.1-rc" ]]; then
    sed -i "s/with-gd/enable-gd/g" ${version}/alpine/Dockerfile
    sed -i "s/--with-png-dir=\/usr\/include\///g" ${version}/alpine/Dockerfile
    sed -i "s/-dir=/=/g" ${version}/alpine/Dockerfile

    #sed -i "s/with-freetype-dir/with-webp/g" ${version}/alpine/Dockerfile
    #sed -i "s/with-webp-dir/with-webp/g" ${version}/alpine/Dockerfile
    #sed -i "s/with-jpeg-dir/with-jpeg/g" ${version}/alpine/Dockerfile
  fi
done
