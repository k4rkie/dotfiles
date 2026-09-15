#!/usr/bin/env bash

mmsg dispatch reload_config

pkill -f mpd-notify.sh
~/scripts/mpd-notify.sh &

pkill swayosd-server 
swayosd-server >/dev/null 2>&1 &

notify-send "Config" "Config reloaded" 
