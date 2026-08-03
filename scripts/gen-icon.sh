#!/usr/bin/env nix-shell
#! nix-shell -i bash -p python3 python3Packages.pillow
# Usage: ./gen-icon.sh <glyph> <name> [color]
# Example: ./gen-icon.sh 󰾪 caffeine-on
# Example: ./gen-icon.sh 󰾪 caffeine-on "#ff0000"

set -e

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <glyph> <name> [color]"
  echo "Example: $0 󰾪 caffeine-on"
  echo "         $0 󰾪 caffeine-on \"#ff0000\""
  exit 1
fi

GLYPH="$1"
NAME="$2"
COLOR="${3:-#ffffff}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ICONS_DIR="$HOME/.local/share/noti-icons"
FONT_FILE="$(fc-match "JetBrainsMono Nerd Font:style=Regular" --format="%{file}")"

mkdir -p "$ICONS_DIR"

python3 -c "
from PIL import Image, ImageDraw, ImageFont
import sys

glyph = sys.argv[1]
path = sys.argv[2]
font_path = sys.argv[3]
hex_color = sys.argv[4].lstrip('#')

r = int(hex_color[0:2], 16)
g = int(hex_color[2:4], 16)
b = int(hex_color[4:6], 16)

size = 96
font = ImageFont.truetype(font_path, 72)
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)
bbox = draw.textbbox((0, 0), glyph, font=font)
w = bbox[2] - bbox[0]
h = bbox[3] - bbox[1]
x = (size - w) // 2 - bbox[0]
y = (size - h) // 2 - bbox[1]
draw.text((x, y), glyph, font=font, fill=(r, g, b, 255))
img.save(path, 'PNG')
print(f'Saved {path}')
" "$GLYPH" "$ICONS_DIR/$NAME.png" "$FONT_FILE" "$COLOR"
