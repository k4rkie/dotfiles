#!/bin/bash
export SWAYSOCK=$(ls /run/user/$UID/sway-ipc.*.sock 2>/dev/null | head -n 1)

ID="1:1:AT_Translated_Set_2_keyboard"

if [[ "$1" == "--toggle" ]]; then
    swaymsg input "$ID" events toggle
    sleep 0.1
fi

STATE=$(swaymsg -t get_inputs | jq -r ".[] | select(.identifier==\"$ID\") | .libinput.send_events")

if [[ "$STATE" == "enabled" ]]; then
    # Outputting valid JSON for Waybar
    echo '{"text": " ", "class": "enabled"}'
else
    echo '{"text": "󰹋 ", "class": "disabled"}'
fi
