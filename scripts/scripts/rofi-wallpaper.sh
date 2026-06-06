#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallhaven"
THUMB_DIR="$HOME/.cache/wallpapers-thumbs"
MONITOR="${1:-eDP-1}"
WALL_FILE="$HOME/.config/hypr/current_wallpaper"

mkdir -p "$THUMB_DIR"

entries=""
while IFS= read -r img; do
    name=$(basename "$img")
    hash=$(sha1sum <<< "$img" | awk '{print $1}')
    thumb="$THUMB_DIR/$hash.jpg"

    if [[ ! -f "$thumb" ]]; then
        magick "$img" -resize 300x "$thumb"
    fi

    entries+="$name\x00icon\x1f$thumb\n"
done < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | sort)

chosen=$(printf "%b" "$entries" | rofi -dmenu -theme ~/.config/rofi/wallpaper.rasi -p "Wallpaper")

if [[ -n "$chosen" ]]; then
    selected=$(find "$WALL_DIR" -maxdepth 1 -type f -name "$chosen" | head -1)
    if [[ -n "$selected" ]]; then
        killall swaybg 2>/dev/null
        swaybg -i "$selected" -m fill &

        abs=$(realpath "$selected")
        echo "$abs" > "$WALL_FILE"

        sed -i "/^background {/,/^}/s|path = .*|path = $abs|" "$HOME/.config/hypr/hyprlock.conf"
        pkill -USR2 hyprlock 2>/dev/null

        notify-send "Wallpaper" "Set to $chosen"
    fi
fi
