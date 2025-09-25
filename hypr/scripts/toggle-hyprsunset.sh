#!/bin/bash

if pgrep -x "hyprsunset" > /dev/null
then
    pkill hyprsunset
    notify-send "󰃚 Hyprsunset OFF"
else
    hyprsunset --temperature 4000 --gamma 80 &
    notify-send "󰖚 Hyprsunset ON"
fi
