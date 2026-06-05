#!/bin/bash
# Usage: ./gen-icon.sh <glyph> <name>
# Example: ./gen-icon.sh 󰾪 caffeine-on

set -e

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <glyph> <name>"
  echo "Example: $0 󰾪 caffeine-on"
  exit 1
fi

GLYPH="$1"
NAME="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ICONS_DIR="$HOME/.local/share/noti-icons"
FONT_FILE="/usr/local/share/fonts/CaskaydiaCoveNerdFont-Regular.ttf"

mkdir -p "$ICONS_DIR"

python3 -c "
from PIL import Image, ImageDraw, ImageFont
import sys

glyph = sys.argv[1]
path = sys.argv[2]
font_path = sys.argv[3]

size = 96
font = ImageFont.truetype(font_path, 72)
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)
bbox = draw.textbbox((0, 0), glyph, font=font)
w = bbox[2] - bbox[0]
h = bbox[3] - bbox[1]
x = (size - w) // 2 - bbox[0]
y = (size - h) // 2 - bbox[1]
draw.text((x, y), glyph, font=font, fill=(255, 255, 255, 255))
img.save(path, 'PNG')
print(f'Saved {path}')
" "$GLYPH" "$ICONS_DIR/$NAME.png" "$FONT_FILE"
