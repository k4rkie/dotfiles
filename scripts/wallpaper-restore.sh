#!/usr/bin/env bash
# Restore the last wallpaper from ~/.cache/quickshell/last-wallpaper.
# Images: plain path → awww. Videos: prefixed with "video:" → mpvpaper.

CACHE_DIR="${HOME}/.cache/quickshell"
CACHE_FILE="${CACHE_DIR}/last-wallpaper"
DEFAULT_WALL="/home/k4rkie/Pictures/Wallhaven/sea_sky_clouds_sand_beach_beacon_sunset_purple.jpg"

mkdir -p "$CACHE_DIR"

if [[ -f "$CACHE_FILE" ]]; then
    entry=$(head -1 "$CACHE_FILE")
else
    entry=""
fi

restore_default() {
    pkill -x mpvpaper 2>/dev/null
    awww query >/dev/null 2>&1 || { awww-daemon &>/dev/null & }
    awww img "$DEFAULT_WALL" --transition-type none
}

case "$entry" in
    video:*)
        video_path="${entry#video:}"
        pkill -x awww-daemon 2>/dev/null
        pkill -x mpvpaper 2>/dev/null
        while pgrep -x 'mpvpaper|awww-daemon' >/dev/null; do sleep 0.05; done
        mpvpaper -f -p -o '--loop-file=inf --no-audio --hwdec=auto' ALL "$video_path"
        ;;
    "")
        restore_default
        ;;
    *)
        pkill -x mpvpaper 2>/dev/null
        awww query >/dev/null 2>&1 || { awww-daemon &>/dev/null & }
        awww img "$entry" --transition-type none
        ;;
esac
