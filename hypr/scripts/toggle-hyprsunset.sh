#!/bin/bash

if pgrep -x "hyprsunset" > /dev/null
then
  pkill hyprsunset
  hyprctl notify -1 3000 "rgb(003366)" "fontsize:20 Hyprsunset OFF"
else
  hyprsunset &
 hyprctl notify -1 3000 "rgb(003366)" "fontsize:20 Hyprsunset ON"
fi
