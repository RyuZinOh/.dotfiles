#!/bin/bash

PIDFILE="/tmp/wf-recorder.pid"
OUTPUT="$HOME/Videos/recording_$(date +%s).mp4"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    hyprctl notify -1 3000 "rgb(003366)" "fontsize:20  Recording Stopped"
else
    wf-recorder -f "$OUTPUT" -r 30 -c libx264 -b 2M -preset ultrafast &
    PID=$!
    
    sleep 0.5
    
    if kill -0 "$PID" 2>/dev/null; then
        echo "$PID" > "$PIDFILE"
        hyprctl notify -1 3000 "rgb(003366)" "fontsize:20  Recording Started: $OUTPUT"
    else
        hyprctl notify -1 3000 "rgb(ff0000)" "fontsize:20  Failed to start recording"
    fi
fi
