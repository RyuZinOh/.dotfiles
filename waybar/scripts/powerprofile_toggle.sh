#!/bin/bash

declare -A ICON=(["power-saver"]="󰌪" ["balanced"]="" ["performance"]="󱄟")
PROFILES=("performance" "balanced" "power-saver")
STATE_FILE="$HOME/.config/waybar/scripts/powerprofile_index"

if [ ! -f "$STATE_FILE" ]; then
    echo 0 > "$STATE_FILE"
fi

CURRENT_INDEX=$(cat "$STATE_FILE")
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#PROFILES[@]} ))
NEXT_PROFILE=${PROFILES[$NEXT_INDEX]}

if [ "$1" == "toggle" ]; then
    powerprofilesctl set "$NEXT_PROFILE"
    echo $NEXT_INDEX > "$STATE_FILE"
    echo "{\"text\":\"${ICON[$NEXT_PROFILE]}\", \"class\":\"$NEXT_PROFILE\", \"tooltip\":\"$NEXT_PROFILE\"}"
    exit 0
fi

CURRENT_PROFILE=${PROFILES[$CURRENT_INDEX]}
echo "{\"text\":\"${ICON[$CURRENT_PROFILE]}\", \"class\":\"$CURRENT_PROFILE\", \"tooltip\":\"$CURRENT_PROFILE\"}"
