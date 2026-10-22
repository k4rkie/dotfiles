#!/usr/bin/env bash

pkill -SIGUSR2 waybar

pkill swayosd-server 
swayosd-server >/dev/null 2>&1 &

notify-send "Config" "Config reloaded" 
