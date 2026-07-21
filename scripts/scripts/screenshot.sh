#!/usr/bin/env bash

# Background the actual capture so rofi (utils-menu) can close immediately.
# The delay inside the function lets rofi's fade-out animation finish
# before grim grabs the screen. Increase this if you still see a ghost.
capture_screenshot() {
    if [[ "$1" == "region" ]]; then
        # Capture the region first, then sleep slightly so slurp's selection UI
        # completely clears from the screen before grim captures it.
        region=$(slurp)
        if [[ -n "$region" ]]; then
            sleep 0.2
            grim -l 1 -g "$region" - | satty --filename - &
        fi
    elif [[ "$1" == "window" ]]; then
        sleep 0.3 # Small delay to let rofi close and focus return to underlying window
        grim -l 1 -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | satty --filename - &
    else
        sleep 0.3 # Small delay to let rofi fade out completely
        grim -l 1 - | satty --filename - &
    fi
}

capture_screenshot "$1" >/dev/null 2>&1 &
