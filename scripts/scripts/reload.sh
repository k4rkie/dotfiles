#!/usr/bin/env bash

hyprctl reload

pkill -SIGUSR2 waybar
killall swaync && swaync &

pkill -f mpd-notify.sh
~/scripts/mpd-notify.sh &

killall swayosd-server && swayosd-server &
killall hypridle && hypridle &

pkill -USR1 hyprlock

notify-send "Hyprland" "Config reloaded" -i "$HOME/.local/share/noti-icons/hyprland.png"
