#!/usr/bin/env bash

dir=$HOME/Pictures/Screenshots
mkdir -p "$dir"
file="$dir/screenshot_$(date +%F_%T).png"

# Background the actual capture so rofi can close immediately.
# The delay inside the function lets rofi's fade-out animation finish
# before grim grabs the screen. Increase this if you still see a ghost.
capture_screenshot() {
    sleep 0.6

    if [[ "$1" == "region" ]]; then
        grim -g "$(slurp)" "$file" || exit 1
    elif [[ "$1" == "window" ]]; then
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$file" || exit 1
    else
        grim "$file" || exit 1
    fi

    notify-send "Screenshot captured" "$(basename "$file")" -i "$file"
}

capture_screenshot "$1" >/dev/null 2>&1 &
