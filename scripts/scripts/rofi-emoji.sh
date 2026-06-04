#!/bin/zsh

EMOJI_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/emoji-list.txt"

if [[ ! -f "$EMOJI_FILE" ]]; then
    curl -sL "https://unicode.org/Public/emoji/latest/emoji-test.txt" \
        | grep -E "^[0-9A-F]" \
        | sed 's/^[^#]*# //; s/ E[0-9.]*//' \
        | sed 's/^\(.\) /\1/' > "$EMOJI_FILE"
fi

chosen=$(cut -d' ' -f1 "$EMOJI_FILE" | rofi -dmenu -p "Emoji" -theme-str 'entry { placeholder: "Search..."; }')

if [[ -n "$chosen" ]]; then
    echo -n "$chosen" | wl-copy
    notify-send "Emoji copied" "$chosen"
fi
