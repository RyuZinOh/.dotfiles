#!/bin/bash
if systemctl is-active --quiet docker; then
  echo '{"text": "󰡨", "tooltip": "Docker: running", "class": "running"}'
else
  echo '{"text": "󰡨", "tooltip": "Docker: not running", "class": "not-running"}'
fi
