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

colors=("#B8B8B8" "#AAA" "#9C9C9C" "#8E8E8E" "#808080" "#727272")

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
