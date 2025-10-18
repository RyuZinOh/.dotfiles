#!/bin/bash
if systemctl is-active --quiet nginx; then
  echo '{"text": "", "tooltip": "Nginx: running", "class": "running"}'
else
  echo '{"text": "", "tooltip": "Nginx: not running", "class": "not-running"}'
fi
