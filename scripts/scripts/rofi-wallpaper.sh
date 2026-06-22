#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallhaven"
ENTRIES_CACHE="$HOME/.cache/wallpapers-menu/entries"
WALL_FILE="$HOME/.config/hypr/current_wallpaper"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# First run: build cache synchronously (slow, unavoidable)
if [[ ! -f "$ENTRIES_CACHE" ]]; then
    "$SCRIPT_DIR/wallpaper-cache.sh"
fi

# Show menu instantly from cache, regenerate in background after
chosen=$(rofi -dmenu -theme ~/.config/rofi/wallpaper.rasi -p "Wallpaper" < "$ENTRIES_CACHE")
("$SCRIPT_DIR/wallpaper-cache.sh" &) &>/dev/null

if [[ -n "$chosen" ]]; then
    selected=$(find "$WALL_DIR" -maxdepth 1 -type f -name "$chosen" | head -1)
    if [[ -n "$selected" ]]; then
        killall swaybg 2>/dev/null
        swaybg -i "$selected" -m fill &

        abs=$(realpath "$selected")
        echo "$abs" > "$WALL_FILE"

        sed -i "/^background {/,/^}/s|path = .*|path = $abs|" "$HOME/.config/hypr/hyprlock.conf"
        pkill -USR2 hyprlock 2>/dev/null

        notify-send "Wallpaper" "Set to $chosen" -i "$HOME/.local/share/noti-icons/image_icon.png"
    fi
fi
