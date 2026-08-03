#!/usr/bin/env bash

MONITOR="eDP-1"

LOCK="pidof hyprlock || hyprlock"
SCREEN_OFF="mmsg dispatch sleep_monitor,$MONITOR"
SCREEN_ON="mmsg dispatch wakeup_monitor,$MONITOR"

exec swayidle \
    timeout 240 "$LOCK" \
    timeout 300 "$SCREEN_OFF" \
    resume "$SCREEN_ON" \
    timeout 600 'systemctl suspend' resume "$SCREEN_ON" \
    before-sleep "$LOCK" \
    after-resume "$SCREEN_ON" \
    idlehint 240
