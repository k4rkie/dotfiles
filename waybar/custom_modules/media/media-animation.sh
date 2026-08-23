#!/usr/bin/env bash

frames=(
  "▁▃▅▇" "▃▅▇▅" "▅▇▅▃" "▇▅▃▁" "▅▃▁▃" "▃▁▃▅"
)
pause_frames=(
  "▁▃▅▇"
  "▃▅▇▅"
  "▅▇▅▃"
  "▇▅▃▁"
  "▅▃▁▃"
  "▃▁▃▅"
)

colors=("#ea6962" "#e78a4e" "#d8a657" "#a9b665" "#7daea3" "#d3869b")

is_audio_playing() {
  wpctl status 2>/dev/null | grep -q '\[active\]'
}

render() {
  local frame=$1 offset=$2 out="" bar_idx color_idx
  for ((bar_idx = 0; bar_idx < ${#frame}; bar_idx++)); do
    color_idx=$(((bar_idx + offset) % ${#colors[@]}))
    out+="<span foreground='${colors[$color_idx]}'>${frame:bar_idx:1}</span>"
  done
  echo "$out"
}

frame_idx=0
num_frames=${#frames[@]}
pause_frame=""
was_playing=true

while :; do
  if is_audio_playing; then
    render "${frames[$frame_idx]}" "$frame_idx"
    frame_idx=$(((frame_idx + 1) % num_frames))
    was_playing=true
    sleep 0.15
  else
    if $was_playing; then
      pause_frame="${pause_frames[RANDOM % ${#pause_frames[@]}]}"
      pause_offset=$((RANDOM % ${#colors[@]}))
      was_playing=false
    fi
    render "$pause_frame" "$pause_offset"
    sleep 0.5
  fi
done
