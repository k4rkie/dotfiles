#!/usr/bin/env bash

CAFFEINE_FILE="/tmp/caffeine"

if [[ -f "$CAFFEINE_FILE" ]]; then
    rm -f "$CAFFEINE_FILE"
    
    pkill -x swayidle
    sleep 0.1
    "$HOME/scripts/idle-handler.sh" &
    
    # notify-send "Caffeine OFF" "Screen will lock normally" \
    #     -i "$HOME/.local/share/noti-icons/caffeine-off.png"
else
    pkill -x swayidle 2>/dev/null
    touch "$CAFFEINE_FILE"
    
    # notify-send "Caffeine ON" "Screen won't lock" \
    #     -i "$HOME/.local/share/noti-icons/caffeine-on.png"
fi
