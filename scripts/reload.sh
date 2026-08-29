#!/usr/bin/env bash

mmsg dispatch reload_config

pkill waybar
waybar &

pkill swaync && swaync &

pkill -f mpd-notify.sh
~/scripts/mpd-notify.sh &

pkill swayosd-server && swayosd-server &

notify-send "Config" "Config reloaded" 
