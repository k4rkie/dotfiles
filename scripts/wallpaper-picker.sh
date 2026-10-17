#!/usr/bin/env bash
# wallpaper picker — replaces quickshell ipc call control openWallpaper
# scans the same folders/extensions as the quickshell WallpaperPage and applies
# through the same path awww/mpvpaper as ControlCenter.apply(), so
# wallpaper-restore.sh and the hyprlock lockscreen keep working untouched.

CACHE_DIR="$HOME/.cache/quickshell"
LOCK_IMG="$CACHE_DIR/lockscreen.png"

# same scan logic as ControlCenter.qml -> scanProc
entry=$( (
    find "$HOME/Pictures/Wallpapers/" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \
        -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \
        -o -iname '*.jxl' -o -iname '*.bmp' -o -iname '*.avif' \) 2>/dev/null
    find "$HOME/Videos/Wallpapers" -type f \( -iname '*.mp4' -o -iname '*.mkv' \
        -o -iname '*.webm' -o -iname '*.mov' \) 2>/dev/null | sed 's/^/VIDEO /'
) | sort | awk -F/ '{print $NF}' | rofi -dmenu -i -p "Wallpaper")

[ -z "$entry" ] && exit 0

# map basename back to full path, keeping the VIDEO tag
if printf '%s' "$entry" | grep -q "^VIDEO "; then
    path=$(printf '%s\n' "$(find "$HOME/Videos/Wallpapers" -type f 2>/dev/null)" | grep "${entry#VIDEO }$")
    is_video=1
else
    path=$(printf '%s\n' "$(find "$HOME/Pictures/Wallpapers/" -type f 2>/dev/null)" | grep "${entry}$")
    is_video=0
fi

case "$is_video" in
    1)
        pkill -x awww-daemon 2>/dev/null
        pkill -x mpvpaper 2>/dev/null
        mkdir -p "$CACHE_DIR"
        echo "video:$path" > "$CACHE_DIR/last-wallpaper"
        ffmpeg -y -ss 00:00:01 -i "$path" -vframes 1 "$LOCK_IMG" >/dev/null 2>&1 &
        mpvpaper -f -p -o '--loop-file=inf --no-audio --hwdec=auto' ALL "$path"
        ;;
    0)
        pkill -x mpvpaper 2>/dev/null
        awww query >/dev/null 2>&1 || { awww-daemon &>/dev/null & \
            for i in $(seq 1 20); do sleep 0.1 && awww query >/dev/null 2>&1 && break; done; \
        }
        awww img "$path" --transition-type random
        cp -f "$path" "$LOCK_IMG"
        echo "$path" > "$CACHE_DIR/last-wallpaper"
        ;;
esac
