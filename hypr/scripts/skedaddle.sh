#!/bin/bash

PIDFILE="/tmp/skedaddle.pid"

# Path to your binary
BINARY="/home/safal726/.config/hypr/scripts/skedaddle.x86_64"

# Check if PID file exists and process is alive
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Process is running → kill it
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "  Skedaddle Stopped"
else
    # Launch the binary in background
    "$BINARY" &
    PID=$!
    sleep 0.2  # give it a moment to start
    if kill -0 "$PID" 2>/dev/null; then
        echo "$PID" > "$PIDFILE"
        notify-send " Skedaddle Started"
    else
        notify-send "  Failed to start Skedaddle"
    fi
fi
