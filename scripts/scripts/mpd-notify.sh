#!/usr/bin/env bash

MUSIC_DIR="$HOME/Music"
CACHE_DIR="$HOME/.cache/mpd-notify"
mkdir -p "$CACHE_DIR"
prev=""

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
            rel=$(mpc current -f "%file%")
            file="$MUSIC_DIR/$rel"
            [ ! -f "$file" ] && file="/var/lib/mpd/music/$rel"
            if [ -f "$file" ]; then
                cover="$CACHE_DIR/cover.jpg"
                ffmpeg -y -i "$file" -an -vcodec copy "$cover" 2>/dev/null
                if [ -s "$cover" ]; then
                    notify-send "Now Playing" "$title" --icon "$cover"
                else
                    notify-send "Now Playing" "$title"
                fi
            else
                notify-send "Now Playing" "$title"
            fi
            ;;
        paused)
            notify-send "Music Paused" "$title" --icon "$cover"
            ;;
    esac
done
