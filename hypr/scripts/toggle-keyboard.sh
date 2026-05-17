#!/bin/zsh
export XDG_RUNTIME_DIR=/run/user/1000
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/)

SILENT=$([[ "$1" == "silent" ]] && echo true || echo false)

notify() {
    [[ "$SILENT" != "true" ]] && notify-send "Keyboard" "$1"
}

# user must create a EXTERNAL_KEYBOARD, INTERNAL_KEYBOARD export variable in their shell pointing their touchpad if exists
if hyprctl devices | rg -q "$EXTERNAL_KEYBOARD"; then
    hyprctl eval "hl.device({ name = '$INTERNAL_KEYBOARD', enabled = false })"
    notify "External keyboard detected... Internal keyboard has been disabled!!"
else
    hyprctl eval "hl.device({ name = '$INTERNAL_KEYBOARD', enabled = true })"
    notify "Internal keyboard has been enabled because external keyboard is disconnected!!"
fi
