#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallhaven"
THUMB_DIR="$HOME/.cache/wallpapers-thumbs"
MONITOR="${1:-eDP-1}"

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
        hyprctl hyprpaper preload "$selected"
        hyprctl hyprpaper wallpaper "$MONITOR,$selected"

        abs=$(realpath "$selected")
        sed -i "s|^preload = .*|preload = $abs|" "$HOME/.config/hypr/hyprpaper.conf"
        sed -i "/^wallpaper {/,/^}/s|path = .*|path = $abs|" "$HOME/.config/hypr/hyprpaper.conf"
        sed -i "/^background {/,/^}/s|path = .*|path = $abs|" "$HOME/.config/hypr/hyprlock.conf"

        notify-send "Wallpaper" "Set to $chosen"
    fi
fi
