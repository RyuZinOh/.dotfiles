#!/bin/zsh
# user must create a TOUCHPAD_DEVICE export variable in their shell pointing their touchpad if exists
STATE_FILE="/tmp/touchpad-state"

apply() {
    local state=$(cat "$STATE_FILE" 2>/dev/null || echo "enabled")
    if [[ "$state" == "disabled" ]]; then
        hyprctl eval "hl.device({ name = '$TOUCHPAD_DEVICE', enabled = false })"
    else
        hyprctl eval "hl.device({ name = '$TOUCHPAD_DEVICE', enabled = true })"
    fi
}

toggle() {
    local state=$(cat "$STATE_FILE" 2>/dev/null || echo "enabled")
    if [[ "$state" == "enabled" ]]; then
        hyprctl eval "hl.device({ name = '$TOUCHPAD_DEVICE', enabled = false })"
        echo "disabled" > "$STATE_FILE"
        notify-send "Touchpad" "Disabled"
    else
        hyprctl eval "hl.device({ name = '$TOUCHPAD_DEVICE', enabled = true })"
        echo "enabled" > "$STATE_FILE"
        notify-send "Touchpad" "Enabled"
    fi
}

case "$1" in
    apply)  apply ;;
    toggle) toggle ;;
    *)      toggle ;;
esac
