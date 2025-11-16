
#!/bin/sh
# Minimal brightness notification script for dunst

# Get current brightness as percentage
get_brightness() {
    brightnessctl g | awk -v max=$(brightnessctl m) '{print int($1/max*100)}'
}

# Send dunst notification with progress bar
notify_brightness() {
    local brightness
    brightness=$(get_brightness)
    dunstify -a "changeBrightness" -t 1500 -r 2594 -u normal -h int:value:"$brightness" "Brightness: ${brightness}%"
}

# Handle up/down actions
case $1 in
    up)
        brightnessctl set +2% >/dev/null
        notify_brightness
        ;;
    down)
        brightnessctl set 2%- >/dev/null
        notify_brightness
        ;;
esac
