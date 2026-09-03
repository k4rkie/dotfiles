#!/usr/bin/env bash
# Generate GTK 3.0 and 4.0 themes from wallust colorscheme

set -euo pipefail

COLORSCHEME="${1:-${HOME}/.config/wallust/colorschemes/black-metal-bathory-tweaked.json}"
CONFIG_DIR="${HOME}/.config/wallust"

if [[ ! -f "${COLORSCHEME}" ]]; then
    echo "Colorscheme not found: ${COLORSCHEME}"
    exit 1
fi

echo "Generating GTK themes from ${COLORSCHEME}..."
wallust cs "${COLORSCHEME}" -d "${CONFIG_DIR}"

echo "GTK themes generated:"
echo "  - ~/.config/gtk-3.0/gtk.css"
echo "  - ~/.config/gtk-4.0/gtk.css"

# Optionally reload GTK apps (uncomment if needed)
# gsettings set org.gnome.desktop.interface gtk-theme '' && gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true