#!/bin/bash

# docker
if systemctl is-active --quiet docker; then
  docker_status=" Docker: "
else
  docker_status=" Docker: "
fi

# mariadb
if systemctl is-active --quiet mariadb; then
  mariadb_status=" MariaDB: "
else
  mariadb_status=" MariaDB: "
fi

# nginx
if systemctl is-active --quiet nginx; then
  nginx_status=" Nginx:  "
else
  nginx_status=" Nginx:  "
fi

echo "$docker_status | $mariadb_status | $nginx_status"
