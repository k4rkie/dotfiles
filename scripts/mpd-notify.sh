#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/mpd-notify"
STATE_FILE="$CACHE_DIR/last"
mkdir -p "$CACHE_DIR"
prev="$(cat "$STATE_FILE" 2>/dev/null || true)"

fetch_cover() {
    cover="$CACHE_DIR/cover-${title//\//_}.img"
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
    state=$(rmpc status | jq -r '.state // ""')
    title=$(rmpc song | jq -r '.metadata.title // ""')
    [ -z "$title" ] && continue

    key="$state:$title"
    [ "$key" = "$prev" ] && continue
    prev="$key"
    printf '%s' "$key" > "$STATE_FILE"

    case "$state" in
        Play)
            if fetch_cover; then
                notify "Now Playing" "$title"
            else
                notify "Now Playing" "$title"
            fi
            ;;
        Pause)
            if fetch_cover; then
                notify "Music Paused" "$title"
            else
                notify "Music Paused" "$title"
            fi
            ;;
    esac

    sleep 1
done
