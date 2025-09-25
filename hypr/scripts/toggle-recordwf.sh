#!/bin/bash

PIDFILE="/tmp/wl-screenrec.pid"
OUTPUT="$HOME/Videos/recording_$(date +%s).mp4"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "  Recording Stopped"
else
    wl-screenrec --filename "$OUTPUT" &
    PID=$!
    sleep 0.5
    if kill -0 "$PID" 2>/dev/null; then
        echo "$PID" > "$PIDFILE"
        notify-send " Recording Started"
    else
        notify-send "  Failed to start recording"
    fi
fi
