#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo -e "\0prompt\x1f  Utils\n"
  echo -e "\0no-custom\x1ftrue\n"
  echo -e " Screenshot Full\n"
  echo -e "󰩬 Screenshot Region\n"
  echo -e " Screenshot Window\n"
  echo -e "󱉶 Tessaract (OCR)\n"
else
  case "$1" in
    " Screenshot Full")
      ~/scripts/screenshot.sh
      ;;
    "󰩬 Screenshot Region")
      ~/scripts/screenshot.sh region
      ;;
    " Screenshot Window")
      ~/scripts/screenshot.sh window
      ;;
    "󱉶 Tessaract (OCR)")
      ~/scripts/ocr-clip.sh
      ;;
  esac
fi
