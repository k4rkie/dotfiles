#!/usr/bin/env bash

# 1. Give Rofi 0.2 seconds to completely disappear before capturing the screen
sleep 0.2

dir=$HOME/Pictures/Screenshots
mkdir -p "$dir"
file="$dir/screenshot_$(date +%F_%T).png"

# 2. Extract the blocking logic into a separate function so we can background it easily
capture_screenshot() {
    if [[ "$1" == "region" ]]; then
        grim -g "$(slurp)" "$file" || exit 1
    elif [[ "$1" == "window" ]]; then
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$file" || exit 1
    else
        grim "$file" || exit 1
    fi

    notify-send "Screenshot captured" "$(basename "$file")" -i "$file"
}

# 3. Call the function with your argument, redirect output, and push it to the background!
capture_screenshot "$1" >/dev/null 2>&1 &
