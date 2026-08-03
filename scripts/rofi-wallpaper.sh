#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallhaven"
ENTRIES_CACHE="$HOME/.cache/wallpapers-menu/entries"
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
        awww img "$selected" --transition-type random

        abs=$(realpath "$selected")
        cat <<EOF > "$HOME/.config/hypr/modules/wallpaper.lua"
-- Current wallpaper path. Set by ~/scripts/rofi-wallpaper.sh
-- Read by modules/autostart.lua at hyprland start.
return "$abs"
EOF

        sed -i "/^background {/,/^}/s|path = .*|path = $abs|" "$HOME/.config/hypr/hyprlock.conf"
        pkill -USR2 hyprlock 2>/dev/null

        notify-send "Wallpaper" "Set to $chosen" -i "$HOME/.local/share/noti-icons/image_icon.png"
    fi
fi
