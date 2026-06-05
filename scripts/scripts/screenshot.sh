#!/usr/bin/env bash

dir=$HOME/Pictures/Screenshots
mkdir -p "$dir"
file="$dir/screenshot_$(date +%F_%T).png"

if [[ "$1" == "region" ]]; then
    grim -g "$(slurp)" "$file" || exit 1
elif [[ "$1" == "window" ]]; then
    grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$file" || exit 1
else
    grim "$file" || exit 1
fi

notify-send "Screenshot captured" "$(basename "$file")" -i "$file"
