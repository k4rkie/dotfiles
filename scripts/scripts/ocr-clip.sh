#!/usr/bin/env bash

# 1. Give Rofi a split second to completely disappear
sleep 0.2

# 2. Wrap everything in a function
run_ocr() {
    TEXT=$(grim -g "$(slurp)" /tmp/ocr.png && tesseract /tmp/ocr.png stdout 2>/dev/null) 

    if [ -z "$TEXT" ]; then
        notify-send "Tesseract" "No text found" -i "/home/k4rkie/.local/share/noti-icons/error.png"
    else
        echo "$TEXT" | wl-copy
        notify-send "Tesseract" "Text copied to clipboard" -i "/home/k4rkie/.local/share/noti-icons/clippy.png"
    fi
}

# 3. Fire and forget! Execute the function in the background.
run_ocr >/dev/null 2>&1 &
