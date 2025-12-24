#!/bin/bash

# cleansing the caches with refresh trigger
CACHE_DIR="$HOME/.cache"

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
