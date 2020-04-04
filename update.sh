#!/bin/bash
### https://blog.dockbit.com/templating-your-dockerfile-like-a-boss-2a84a67d28e9
render() {
sedStr="
  s!%%PHP_VERSION%%!$version!g;
"

sed -r "$sedStr" $1
}

versions=(7.1 7.2 7.3 7.4)
for version in ${versions[*]}; do
  render Dockerfile-alpine.template > $version/alpine/Dockerfile
done
