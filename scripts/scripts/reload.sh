#!/usr/bin/env bash

hyprctl reload

pkill -SIGUSR2 waybar
killall swaync && swaync &

killall swayosd-server && swayosd-server &
killall hypridle && hypridle &

pkill -USR1 hyprlock

gsettings set org.gnome.desktop.interface font-name 'IosevkaTerm Nerd Font 12'
gsettings set org.gnome.desktop.interface gtk-theme 'Void'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

notify-send "Hyprland" "Config reloaded"
