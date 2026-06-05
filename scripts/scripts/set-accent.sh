#!/usr/bin/env bash
set -euo pipefail

NEW_COLOR="${1:-}"
if [[ -z "$NEW_COLOR" ]]; then
  echo "Usage: $0 <hexcolor>"
  echo "  $0 '#4e5687'"
  exit 1
fi

THEME_DIR="$HOME/dotfiles/themes/Void"

# Grab current accent from the source (so it works no matter what it is)
CURRENT=$(grep -h 'selected_bg_color:' "$THEME_DIR/gtk-3.0/_colors.scss" | head -1 | sed 's/.*: *//' | tr -d ' ;')

find "$THEME_DIR" -name '*.scss' -exec sed -i "s/$CURRENT/$NEW_COLOR/g" {} +
find "$THEME_DIR" -name 'gtkrc'   -exec sed -i "s/$CURRENT/$NEW_COLOR/g" {} +

cd "$THEME_DIR"
sass --no-source-map gtk-3.0/gtk.scss         gtk-3.0/gtk.css
sass --no-source-map gtk-3.0/gtk-dark.scss     gtk-3.0/gtk-dark.css
sass --no-source-map gtk-4.0/gtk.scss          gtk-4.0/gtk.css
sass --no-source-map gtk-4.0/gtk-dark.scss     gtk-4.0/gtk-dark.css
sass --no-source-map gnome-shell/gnome-shell.scss gnome-shell/gnome-shell.css
sass --no-source-map cinnamon/cinnamon.scss     cinnamon/cinnamon.css
sass --no-source-map cinnamon/cinnamon-dark.scss cinnamon/cinnamon-dark.css

cp gtk-3.0/gtk.css gtk-3.0/gtk-dark.css         /usr/share/themes/Void/gtk-3.0/
cp gtk-4.0/gtk.css gtk-4.0/gtk-dark.css         /usr/share/themes/Void/gtk-4.0/
cp gnome-shell/gnome-shell.css                   /usr/share/themes/Void/gnome-shell/
cp cinnamon/cinnamon.css cinnamon/cinnamon-dark.css /usr/share/themes/Void/cinnamon/
cp gtk-2.0/gtkrc                                 /usr/share/themes/Void/gtk-2.0/

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
sleep 0.5
gsettings set org.gnome.desktop.interface gtk-theme "Void"

# Keep override CSS files in sync
for f in "$HOME/dotfiles/gtk/.config/gtk-3.0/gtk.css" "$HOME/dotfiles/gtk/.config/gtk-4.0/gtk.css"; do
  sed -i "s/$CURRENT/$NEW_COLOR/g" "$f"
done

echo "Accent changed to $NEW_COLOR"
