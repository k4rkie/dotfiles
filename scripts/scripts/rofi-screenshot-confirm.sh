#!/usr/bin/env bash

shot="$1"
[[ -f "$shot" ]] || exit 1

# Rofi's `background-image: url(...)` reads from a fixed path, so point a
# stable preview file at the just-taken shot.
preview="/tmp/rofi-screenshot-preview.png"
cp "$shot" "$preview"

# Compact menu — nerd-font glyphs stay inline with the text (horizontal layout).
choice=$(printf '%s\n%s\n%s\n' \
    " Save" \
    "󰆏 Copy" \
    " Discard" \
    | rofi -dmenu -i -no-custom \
        -theme ~/.config/rofi/screenshot-confirm.rasi \
        -p "" \
        -selected-row 0)

# Tidy up the preview regardless of choice.
rm -f "$preview"

case "$choice" in
    " Save")
        dest_dir="$HOME/Pictures/Screenshots"
        mkdir -p "$dest_dir"
        dest="$dest_dir/screenshot_$(date +%F_%H-%M-%S).png"
        mv "$shot" "$dest"
        notify-send "Screenshot saved" "$(basename "$dest")" -i "$dest"
        ;;
    "󰆏 Copy")
        wl-copy < "$shot"
        notify-send "Screenshot" "Copied to clipboard" -i "$shot"
        rm -f "$shot"
        ;;
    " Discard")
        rm -f "$shot"
        notify-send "Screenshot" "Discarded"
        ;;
    *)
        # Esc / no selection — treat as discard, silently
        rm -f "$shot"
        ;;
esac
