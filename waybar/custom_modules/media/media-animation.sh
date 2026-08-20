#!/usr/bin/env bash

is_audio_playing() {
  wpctl status 2>/dev/null | grep -q '\[active\]'
}

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
pause_frame=${animation_frames[RANDOM % ${#animation_frames[@]}]}
while :; do
  for frame in "${animation_frames[@]}"; do
    if is_audio_playing; then
        pause_frame=${animation_frames[RANDOM % ${#animation_frames[@]}]}
        echo "$frame"
    else
        echo "${pause_frame}"
    fi
    sleep 0.2
  done
done
