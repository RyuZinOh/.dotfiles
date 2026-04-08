#!/bin/bash

PROCESS="wl-screenrec"
AUDIO_SOURCE="$(pactl get-default-sink).monitor"

if pgrep -x "$PROCESS" >/dev/null; then
  pkill -INT -x "$PROCESS"
  notify-send "Screen Recorder" "Recording stopped."
else
  REGION=$(slurp)
  [ -z "$REGION" ] && exit 1
  OUTPUT="$HOME/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4"

  wl-screenrec --audio --audio-device "$AUDIO_SOURCE" -g "$REGION" -f "$OUTPUT" &

  notify-send "Screen Recorder" "Recording started (internal audio, region)."
fi
