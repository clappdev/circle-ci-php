#!/bin/bash
ln -s /data/node_modules /usr/share/nginx/html/node_modules
service php5-fpm restart && nginx -g 'daemon off;'
