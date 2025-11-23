#!/usr/bin/env bash

# ask for filename as user input
read -p "Enter filename: " filename

# Store the recording in the ~/Videos/ directory
output=$HOME/Videos/$filename.mp4

if [[ -f "$output" ]]; then
  echo "File already exists!"
  exit 1
fi

echo "Recording has started!!"
echo "Press Ctrl+C to stop recording."

wf-recorder -c h264_vaapi -a -i alsa_input.usb-Generic_USB2.0_Device_20170726905957-00.mono-fallback -f "$output"
