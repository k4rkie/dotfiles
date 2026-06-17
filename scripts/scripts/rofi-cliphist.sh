#!/usr/bin/env bash

selection=$(cliphist list | rofi -dmenu -p "Clipboard" -display-columns 2 \
  -kb-custom-1 "Alt+d")

case $? in
  10) cliphist wipe && notify-send "Clipboard" "History cleared" ;;
  1) exit 0 ;;
  *) echo "$selection" | cliphist decode | wl-copy ;;
esac
