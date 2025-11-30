#!/bin/bash
PIDFILE="/tmp/wl-screenrec.pid"
OUTPUT="$HOME/Videos/recording_$(date +%s).mp4"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  kill -INT "$(cat "$PIDFILE")"
  rm -f "$PIDFILE"
  notify-send "  Recording Stopped"
else
  GEOMETRY=$(slurp)

  if [ -z "$GEOMETRY" ]; then
    notify-send "Recording cancelled!!"
    exit 1
  fi

  AUDIO_SOURCE=$(pactl get-default-sink).monitor

  wl-screenrec --audio --audio-device "$AUDIO_SOURCE" --geometry "$GEOMETRY" -f "$OUTPUT" &
  PID=$!
  sleep 0.5
  if kill -0 "$PID" 2>/dev/null; then
    echo "$PID" >"$PIDFILE"
    notify-send "Recording Started" "Region: $GEOMETRY"
  else
    notify-send "   Failed to start recording"
  fi
fi
