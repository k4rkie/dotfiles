#!/usr/bin/env bash

CAFFEINE_FILE="/tmp/caffeine"

if [[ -f "$CAFFEINE_FILE" ]]; then
  rm -f "$CAFFEINE_FILE"
  pidof swayidle >/dev/null && { pkill swayidle; swayidle -w & } || hypridle &
  notify-send "Caffeine OFF" "Screen will lock normally" -i "$HOME/.local/share/noti-icons/caffeine-off.png"
else
  pkill swayidle 2>/dev/null; pkill hypridle 2>/dev/null
  touch "$CAFFEINE_FILE"
  notify-send "Caffeine ON" "Screen won't lock" -i "$HOME/.local/share/noti-icons/caffeine-on.png"
fi

# kill -SIGUSR1 waybar
