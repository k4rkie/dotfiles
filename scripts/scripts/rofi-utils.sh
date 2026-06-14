#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo -e "\0prompt\x1fUtils"
    echo -e "\0no-custom\x1ftrue"
    echo "Screenshot Full"
    echo "Screenshot Region"
    echo "OCR Capture"
else
    case "$1" in
        "Screenshot Full")
            $HOME/dotfiles/scripts/scripts/screenshot.sh
            ;;
        "Screenshot Region")
            $HOME/dotfiles/scripts/scripts/screenshot.sh region 
            ;;
        "OCR Capture")
            $HOME/dotfiles/scripts/scripts/ocr-clip.sh
            ;;
    esac
fi
