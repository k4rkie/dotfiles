#!/usr/bin/env bash

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
while :; do
  for frame in "${animation_frames[@]}"; do
    status=$(mpc status '%state%' 2>/dev/null)

    if [ "$status" == "playing" ]; then
        echo "$frame"
    elif [ "$status" == "paused" ]; then
        echo ""
    else
        echo ""
    fi
    sleep 0.3
  done
done
