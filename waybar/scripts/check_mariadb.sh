#!/bin/bash
if systemctl is-active --quiet mariadb; then
  echo '{"text": "", "tooltip": "MariaDB: running", "class": "running"}'
else
  echo '{"text": "", "tooltip": "MariaDB: not running", "class": "not-running"}'
fi
