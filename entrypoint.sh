#!/bin/bash

sed -i "s#<resolver>#$DOCKER_DNS#g" /usr/local/openresty/nginx/conf/nginx.conf

exec /usr/bin/openresty -g "daemon off;"