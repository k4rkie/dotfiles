#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$PATH"

zscroll -l 20 \
    --delay 0.3 \
    --update-check true \
    "mpc current" 2>/dev/null

wait
