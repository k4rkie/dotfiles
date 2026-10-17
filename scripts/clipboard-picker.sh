#!/usr/bin/env bash
# clipboard history picker — replaces quickshell ipc call control openClipboard
# depends: cliphist, rofi, wl-clipboard (all already installed)

PATHS=/home/k4rkie

item=$(cliphist list | rofi -dmenu -i -p "Clipboard")
[ -z "$item" ] && exit 0

echo "$item" | cliphist decode | wl-copy
