#!/usr/bin/env bash

hyprctl reload

pkill -SIGUSR2 waybar
pkill swaync; swaync &

pkill -f mpd-notify.sh
~/scripts/mpd-notify.sh &

pkill swayosd-server; swayosd-server &
pkill hypridle; hypridle &

pkill -USR1 hyprlock

notify-send "Hyprland" "Config reloaded" -i "$HOME/.local/share/noti-icons/hyprland.png"
