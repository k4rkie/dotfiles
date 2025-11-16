#!/bin/bash

battery_level=$(acpi -b | grep -o '[0-9]\+%' | tr -d '%')
status=$(acpi -a | awk '{print $3}')

if [[ "$battery_level" -le 30 && "$status" == "off-line" ]]; then
    notify-send "Low Battery ⚠️" "Battery at ${battery_level}%. Plug in the charger."
fi
