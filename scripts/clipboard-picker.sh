#!/usr/bin/env bash

PATHS=/home/k4rkie

item=$(cliphist list | awk '{ print $2 }' | rofi -dmenu -i -p "  Clipboard")
[ -z "$item" ] && exit 0

echo -n "$item" | wl-copy
