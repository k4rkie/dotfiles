#!/usr/bin/env bash

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOTS_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
output="$SCREENSHOTS_DIR/screenshot_${timestamp}.png"

# ppm via pipe is ~100-200ms faster than PNG temp file (no compress/decompress)
# satty recommends: grim -t ppm - | satty --filename -
if [[ "$1" == "region" ]]; then
    region="$(slurp)"

    [[ -z "$region" ]] && exit 0

    sleep 0.2
    grim -g "$region" -t ppm - | satty \
        --filename - \
        --copy-command "wl-copy" --actions-on-enter "save-to-clipboard,save-to-file" \
        --early-exit \
        --output-filename "$output"

elif [[ "$1" == "window" ]]; then
    sleep 0.3

    geometry="$(swaymsg -t get_tree | jq -r \
        '.. | select(.focused? == true) | .rect |
        "\(.x),\(.y) \(.width)x\(.height)"')"

    grim -g "$geometry" -t ppm - | satty \
        --filename - \
        --copy-command "wl-copy" --actions-on-enter "save-to-clipboard,save-to-file" \
        --early-exit \
        --output-filename "$output"

else
    sleep 0.3
    grim -t ppm - | satty \
        --filename - \
        --copy-command "wl-copy" --actions-on-enter "save-to-clipboard,save-to-file" \
        --early-exit \
        --output-filename "$output"
fi
