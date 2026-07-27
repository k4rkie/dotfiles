#!/usr/bin/env bash

# Reload compositor config
if pgrep -x Hyprland >/dev/null; then
  hyprctl reload
  pkill hypridle && hypridle &
  pkill -USR1 hyprlock 2>/dev/null
elif pgrep -x mango >/dev/null; then
  mmsg dispatch reload_config
  # swayidle is exec-once, handled by mango on reload
  pkill -f swaylock 2>/dev/null
fi

pkill -SIGUSR2 waybar
pkill swaync && swaync &

pkill -f mpd-notify.sh
~/scripts/mpd-notify.sh &

pkill swayosd-server && swayosd-server &

notify-send "Config" "Config reloaded" -i "$HOME/.local/share/noti-icons/hyprland.png"
