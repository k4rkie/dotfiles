#
# #!/bin/sh
# # Minimal PipeWire volume notification for dunst (text + progress bar only)
#
# # Get current volume as percentage
# get_volume() {
#     wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($1*100)}'
# }
#
# # Check if muted
# is_mute() {
#     wpctl get-mute @DEFAULT_AUDIO_SINK@ | grep -q yes
# }
#
# # Send dunst notification with progress bar
# notify_volume() {
#     local volume
#     volume=$(get_volume)
#     dunstify -a "changeVolume" -t 1500 -r 2593 -u normal -h int:value:"$volume" "Volume: ${volume}%"
# }
#
# # Send mute notification
# notify_mute() {
#     dunstify -a "changeVolume" -t 1500 -r 2593 -u normal "Volume: Mute"
# }
#
# # Handle up/down/mute actions
# case $1 in
#     up)
#         wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
#         notify_volume
#         ;;
#     down)
#         wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
#         notify_volume
#         ;;
#     mute)
#         wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
#         if is_mute; then
#             notify_mute
#         else
#             notify_volume
#         fi
#         ;;
# esac
#
#
#!/bin/sh
# Minimal PipeWire volume notification (average channels)

# Get current volume as percentage (average all channels)
get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print int(sum/NF*200)}'
}

# Check if muted
is_mute() {
    # wpctl get-mute @DEFAULT_AUDIO_SINK@ | grep -q yes
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q '\[MUTED\]'
}

# Send dunst notification with progress bar
notify_volume() {
    local volume
    volume=$(get_volume)
    dunstify -a "changeVolume" -t 1500 -r 2593 -u normal -h int:value:"$volume" "Volume: ${volume}%"
}

# Send mute notification
notify_mute() {
    dunstify -a "changeVolume" -t 1500 -r 2593 -u normal "Volume: Mute"
}

# Handle up/down/mute actions
case $1 in
    up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+
        notify_volume
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-
        notify_volume
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if is_mute; then
            notify_mute
        else
            notify_volume
        fi
        ;;
esac
