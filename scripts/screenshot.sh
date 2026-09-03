#!/usr/bin/env bash

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOTS_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
output="$SCREENSHOTS_DIR/screenshot_${timestamp}.png"
tmp="/tmp/qs-screenshot.png"

if [[ "$1" == "region" ]]; then
    region="$(slurp)"

    [[ -z "$region" ]] && exit 0

    sleep 0.2
    grim -g "$region" "$tmp"

elif [[ "$1" == "window" ]]; then
    sleep 0.3

    geometry="$(swaymsg -t get_tree | jq -r \
        '.. | select(.focused? == true) | .rect |
        "\(.x),\(.y) \(.width)x\(.height)"')"

    grim -g "$geometry" "$tmp"

else
    sleep 0.3
    grim "$tmp"
fi

satty \
    --filename "$tmp" \
    --actions-on-enter "save-to-file" \
    --early-exit \
    --output-filename "$output"
