#!/usr/bin/env bash

CAFFEINE_FILE="/tmp/caffeine"

if [[ -f "$CAFFEINE_FILE" ]]; then
    rm -f "$CAFFEINE_FILE"
    
    pkill -x swayidle
    sleep 0.1
    "$HOME/scripts/idle-handler.sh" &
else
    pkill -x swayidle 2>/dev/null
    touch "$CAFFEINE_FILE"
fi
