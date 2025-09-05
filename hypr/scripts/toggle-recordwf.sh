#!/bin/bash

PIDFILE="/tmp/wl-screenrec.pid"
OUTPUT="$HOME/Videos/recording_$(date +%s).mp4"

notify() {
    hyprctl notify 1 3000 "rgb(ffffff)" "$1"
}

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify "Recording Stopped"
else
    wl-screenrec --filename "$OUTPUT" &
    PID=$!
    sleep 0.5
    if kill -0 "$PID" 2>/dev/null; then
        echo "$PID" > "$PIDFILE"
        notify "Recording Started"
    else
        notify "Failed to start recording"
    fi
fi
