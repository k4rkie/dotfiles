#!/usr/bin/env bash

# Reload compositor config
if pgrep -x Hyprland >/dev/null; then
  hyprctl reload
  pkill hypridle && hypridle &
  pkill -USR1 hyprlock 2>/dev/null
elif pgrep -x mango >/dev/null; then
  mmsg dispatch reload_config
  pkill hyprlock 2>/dev/null
fi

pkill waybar
pkill quickshell
waybar &
quickshell

pkill swaync && swaync &

pkill -f mpd-notify.sh
~/scripts/mpd-notify.sh &

pkill swayosd-server && swayosd-server &

notify-send "Config" "Config reloaded" 
