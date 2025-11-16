#!/bin/bash

SOURCE_DIR="/home/safal726/Pictures"
THUMBS_DIR="/home/safal726/thumbs"
THUMB_SIZE="350x200"

# Colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

# Nerd font icons
ICON_IMAGE=""
ICON_SUCCESS=""
ICON_LOADING=""
ICON_CAMERA=""

# create thumbs folder if it doesn't exist
mkdir -p "$THUMBS_DIR"
echo -e "${CYAN}${ICON_LOADING} Preparing thumbnails folder...${RESET}"

for IMG in "$SOURCE_DIR"/*.{jpg,JPG,jpeg,JPEG}; do
    [ -e "$IMG" ] || continue  # Skip if no files match

    BASENAME=$(basename "$IMG")
    THUMB_FILE="$THUMBS_DIR/$BASENAME"

    # Skip if thumbnail already exists
    if [ -e "$THUMB_FILE" ]; then
        echo -e "${BLUE}${ICON_CAMERA} Thumbnail already exists for $BASENAME, skipping...${RESET}"
        continue
    fi

    echo -ne "${YELLOW}${ICON_LOADING} Processing $BASENAME ${RESET}"
    magick "$IMG" -thumbnail "${THUMB_SIZE}^" -gravity center -extent "$THUMB_SIZE" "$THUMB_FILE"
    echo -e "\r${GREEN}${ICON_SUCCESS} Thumbnail created: ${ICON_IMAGE} $THUMB_FILE${RESET}"
done

echo -e "${CYAN}${ICON_LOADING} Checking for orphan thumbnails...${RESET}"

for THUMB in "$THUMBS_DIR"/*.{jpg,JPG,jpeg,JPEG}; do
    [ -e "$THUMB" ] || continue

    BASENAME=$(basename "$THUMB")
    ORIGINAL="$SOURCE_DIR/$BASENAME"

    # if original image does not exist, delete the thumbnail
    if [ ! -e "$ORIGINAL" ]; then
        echo -e "${RED}Deleting orphan thumbnail: $BASENAME${RESET}"
        rm "$THUMB"
    fi
done

echo -e "${MAGENTA} All operations completed successfully!${RESET}"
