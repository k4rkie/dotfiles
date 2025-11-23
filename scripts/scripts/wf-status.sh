
#!/usr/bin/env bash

# Check if wf-recorder is running
if pgrep -x wf-recorder >/dev/null; then
    echo " 󰻃 REC"
    echo "#ff0000"  # red color
else
    echo " 󰒲 Idle"
    echo "#00ff00"  # green color
fi
