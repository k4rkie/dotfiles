#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallhaven"
THUMB_DIR="$HOME/.cache/wallpapers-thumbs"
ENTRIES_CACHE="$HOME/.cache/wallpapers-menu/entries"

mkdir -p "$THUMB_DIR" "$(dirname "$ENTRIES_CACHE")"

while IFS= read -r img; do
    name=$(basename "$img")
    hash=$(sha1sum <<< "$img" | awk '{print $1}')
    thumb="$THUMB_DIR/$hash.jpg"
    [[ ! -f "$thumb" ]] && magick "$img" -resize 300x "$thumb"
    printf "%s\x00icon\x1f%s\n" "$name" "$thumb"
done < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | sort) > "$ENTRIES_CACHE.tmp" && mv "$ENTRIES_CACHE.tmp" "$ENTRIES_CACHE"
