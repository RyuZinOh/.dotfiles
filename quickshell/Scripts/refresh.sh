# #!/bin/bash
#
# # cleansing the caches with refresh trigger
# CACHE_DIR="$HOME/.cache"
# HOME_DIR="$HOME"
# CONFIG_DIR="$HOME/.config"
#
# static_dirs=(
#   "glycin"
#   "gegl-0.4"
#   "babl"
#   "thumbnails"
#   "ImageMagick"
#   "Microsoft"
#   "mozilla"
#   "net.imput.helium"
#   "gstreamer-1.0"
#   "mesa_shader_cache"
#   "QtProject"
#   "quickshell"
#   "paru"
#   "pip"
#   "pipx"
#   "lutris"
# )
#
# for dir in "${static_dirs[@]}"; do
#   if [ -d "$CACHE_DIR/$dir" ]; then
#     rm -rf "$CACHE_DIR/$dir"
#   fi
# done
#
# find "$CACHE_DIR" -maxdepth 1 -type f -name "event-*" -delete
# find "$CACHE_DIR" -maxdepth 1 -type d -name "qtshadercache*" -exec rm -rf {} +
# find "$CACHE_DIR" -maxdepth 1 -type d -name "umu*" -exec rm -rf {} +
# find "$CONFIG_DIR" -maxdepth 1 -type d -name "dconf*" -exec rm -rf {} +
# find "$CONFIG_DIR" -maxdepth 1 -type d -name "btop*" -exec rm -rf {} +
# find "$CONFIG_DIR" -maxdepth 1 -type d -name "gtk*" -exec rm -rf {} +
# find "$CONFIG_DIR" -maxdepth 1 -type d -name "pulse*" -exec rm -rf {} +
# rm -f "$HOME_DIR/.zcompdump-archlinux-5.9.1"
# rm -f "$HOME_DIR/.zcompdump-archlinux-5.9.1.zwc"
# rm -rf "$HOME_DIR/.pki"
# rm -f "$HOME_DIR/.zsh_history"
# rm -f "$HOME_DIR/.bash_history"
# rm -f "$HOME_DIR/.mariadb_history"
# rm -f "$HOME_DIR/.wget-hsts"
# rm -f "$HOME_DIR/.config/mimeapps.list"
# find /tmp -mindepth 1 -user "$USER" -exec rm -rf {} + 2>/dev/null
