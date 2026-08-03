#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/mpd-notify"
mkdir -p "$CACHE_DIR"
prev=""

fetch_cover() {
    cover="$CACHE_DIR/cover.img"
    if rmpc albumart --output "$cover" >/dev/null 2>&1 && [ -s "$cover" ]; then
        return 0
    fi
    rm -f "$cover"
    cover=""
    return 1
}

notify() {
    local summary="$1" body="$2"
    if [ -n "$cover" ] && [ -s "$cover" ]; then
        notify-send "$summary" "$body" --icon "$cover"
    else
        notify-send "$summary" "$body"
    fi
}

while true; do
    mpc idle player > /dev/null 2>&1

    state=$(mpc status "%state%")
    title=$(mpc current)
    [ -z "$title" ] && continue

    key="$state:$title"
    [ "$key" = "$prev" ] && continue
    prev="$key"

    case "$state" in
        playing)
            if fetch_cover; then
                notify "Now Playing" "$title"
            else
                notify "Now Playing" "$title"
            fi
            ;;
        paused)
            if fetch_cover; then
                notify "Music Paused" "$title"
            else
                notify "Music Paused" "$title"
            fi
            ;;
    esac
done