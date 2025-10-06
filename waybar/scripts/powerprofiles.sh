#!/usr/bin/env bash

get_icon() {
  case "$1" in
    performance) echo "󰓅 " ;; 
    balanced) echo " " ;;    
    power-saver) echo "󰌪 " ;;   
  esac
}

get_label() {
  case "$1" in
    performance) echo "Performance" ;;
    balanced) echo "Balanced" ;;
    power-saver) echo "Power Saver" ;;
  esac
}

notify() {
  local profile="$1"
  local icon
  icon=$(get_icon "$profile")
  local label
  label=$(get_label "$profile")
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Power Profile" "$icon  Switched to $label"
  fi
}

# Current profile
current=$(powerprofilesctl get)

# No args = display current icon for Waybar
if [[ -z "$1" ]]; then
  icon=$(get_icon "$current")
  echo "$icon"
  exit 0
fi

# Handle click actions
case "$1" in
  toggle)
    case "$current" in
      performance)
        powerprofilesctl set balanced
        notify balanced
        ;;
      balanced)
        powerprofilesctl set power-saver
        notify power-saver
        ;;
      power-saver)
        powerprofilesctl set performance
        notify performance
        ;;
    esac
    ;;
esac
