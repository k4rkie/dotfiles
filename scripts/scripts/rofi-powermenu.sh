#!/usr/bin/env bash
set -e
set -u

# Single self-contained theme
theme="$HOME/.config/rofi/powermenu.rasi"

# Icons (Nerd Font)
shutdown='󰐥'
reboot='󰜉'
lock='󰍁'
suspend='󰤄'
logout='󰍃'
yes='󰄬'
no='󰅖'

# System info
format_uptime() {
    local input="$1"
    local output=""

    # Extract days
    if [[ "$input" =~ ([0-9]+)[[:space:]]+days? ]]; then
        output="${BASH_REMATCH[1]}d "
        input=$(echo "$input" | sed -E 's/[0-9]+[[:space:]]+days?[[:space:]]*//')
    fi

    # Extract hours and minutes from HH:MM
    if [[ "$input" =~ ([0-9]+):([0-9]+) ]]; then
        local h=$((10#${BASH_REMATCH[1]}))
        local m=$((10#${BASH_REMATCH[2]}))
        [ "$h" -gt 0 ] && output="${output}${h}h "
        [ "$m" -gt 0 ] && output="${output}${m}m"
    # Extract minutes only
    elif [[ "$input" =~ ([0-9]+)[[:space:]]+min ]]; then
        output="${output}${BASH_REMATCH[1]}m"
    fi

    # Trim trailing spaces
    echo "$output" | sed 's/ *$//'
}

raw_uptime=$(uptime | sed -n 's/.*up \([^,]*\),.*/\1/p' | sed 's/  */ /g')
uptime=$(format_uptime "$raw_uptime")
host=$(hostname)

rofi_cmd() {
    rofi -dmenu \
        -p "Goodbye ${USER}" \
        -mesg "Uptime: $uptime" \
        -theme "$theme" \
        -window-title "powermenu" 
}

confirm_cmd() {
    rofi -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you sure?' \
        -theme "$theme" \
        -theme-str 'window { fullscreen: false; width: 500px; background-color: @background; }' \
        -theme-str 'mainbox { children: [ "message", "listview" ]; margin: 0px; padding: 30px; spacing: 30px; }' \
        -theme-str 'message { margin: 0px; padding: 20px; }' \
        -theme-str 'listview { columns: 2; lines: 1; spacing: 30px; }' \
        -theme-str 'element { padding: 60px 10px; background-color: @background-alt; }' \
        -theme-str 'element-text { font: var(confirm-element-text-font); }' \
        -window-title "powermenu-confirm" 
}

confirm_exit() {
    printf '%s\n%s\n' "$yes" "$no" | confirm_cmd
}

run_rofi() {
    # Order matches adi1090x type-4 style-2: lock, suspend, logout, reboot, shutdown
    printf '%s\n%s\n%s\n%s\n%s\n' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" | rofi_cmd
}

run_cmd() {
    selected=$(confirm_exit)
    if [ "$selected" = "$yes" ]; then
        case "$1" in
            --shutdown) systemctl poweroff ;;
            --reboot)   systemctl reboot ;;
            --suspend)  systemctl suspend ;;
            --logout)   loginctl terminate-session "${XDG_SESSION_ID-}" ;;
        esac
    fi
}

chosen=$(run_rofi)
case "$chosen" in
    "$shutdown")
        run_cmd --shutdown
        ;;
    "$reboot")
        run_cmd --reboot
        ;;
    "$lock")
        pidof swaylock || pidof hyprlock || swaylock -f
        ;;
    "$suspend")
        swaylock -f; sleep 0.5; run_cmd --suspend
        ;;
    "$logout")
        run_cmd --logout
        ;;
esac
