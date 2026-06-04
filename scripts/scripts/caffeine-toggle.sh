#!/bin/zsh

CAFFEINE_FILE="/tmp/caffeine"

if [[ -f "$CAFFEINE_FILE" ]]; then
  rm -f "$CAFFEINE_FILE"
  hypridle &
  notify-send " Caffeine OFF" "Screen will lock normally"
else
  pkill hypridle
  touch "$CAFFEINE_FILE"
  notify-send "󰅶 Caffeine ON" "Screen won't lock"
fi

kill -SIGUSR1 waybar
