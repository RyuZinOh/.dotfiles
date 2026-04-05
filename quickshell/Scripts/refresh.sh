#!/bin/bash

# cleansing the caches with refresh trigger
CACHE_DIR="$HOME/.cache"
HOME_DIR="$HOME"

static_dirs=(
  "glycin"
  "gegl-0.4"
  "babl"
  "thumbnails"
  "ImageMagick"
  "Microsoft"
  "mozilla"
  "gstreamer-1.0"
  "mesa_shader_cache"
  "QtProject"
  "quickshell"
)

for dir in "${static_dirs[@]}"; do
  if [ -d "$CACHE_DIR/$dir" ]; then
    rm -rf "$CACHE_DIR/$dir"
  fi
done

find "$CACHE_DIR" -maxdepth 1 -type f -name "event-*" -delete
find "$CACHE_DIR" -maxdepth 1 -type d -name "qtshadercache*" -exec rm -rf {} +
rm -f "$HOME_DIR/.zcompdump-archlinux-5.9"
rm -f "$HOME_DIR/.zcompdump-archlinux-5.9.zwc"
rm -rf "$HOME_DIR/.pki"
rm -f "$HOME_DIR/.zsh_history"
find /tmp -mindepth 1 -user "$USER" -exec rm -rf {} + 2>/dev/null
