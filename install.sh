#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"
CONFIG_DIR="$HOME_DIR/.config"
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --force) FORCE=true; shift ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "  --dry-run   Show what would be linked without making changes"
            echo "  --force     Remove existing files/dirs before symlinking"
            echo "  -h, --help  Show this help"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

link() {
    local source="$1"
    local target="$2"
    local source_resolved
    source_resolved="$(readlink -f "$source")"

    if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$source_resolved" ]]; then
        echo "[OK]   $target -> $source"
        return
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$FORCE" == true ]]; then
            echo "[FORCE] Removing existing $target"
            [[ "$DRY_RUN" == true ]] || rm -rf "$target"
        else
            echo "[SKIP] $target already exists (use --force to overwrite)"
            return
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY]  ln -s $source $target"
    else
        mkdir -p "$(dirname "$target")"
        ln -s "$source" "$target"
        echo "[LINK] $target -> $source"
    fi
}

echo "Dotfiles install script"
echo "Dotfiles dir: $DOTFILES_DIR"
echo "Home dir:     $HOME_DIR"
echo "Config dir:   $CONFIG_DIR"
[[ "$DRY_RUN" == true ]] && echo "MODE: DRY RUN"
echo "---"

declare -A CONFIG_SYMLINKS=(
    [foot]=foot
    [hypr]=hypr
    [mango]=mango
    [mpd]=mpd
    [mpv]=mpv
    [nvim]=nvim
    [quickshell]=quickshell
    [rmpc]=rmpc
    [rofi]=rofi
    [sway]=sway
    [swaync]=swaync
    [swayosd]=swayosd
    [tmux]=tmux
    [waybar]=waybar
    [yazi]=yazi
    [zathura]=zathura
    [zed]=zed
)

for name in "${!CONFIG_SYMLINKS[@]}"; do
    link "$DOTFILES_DIR/$name" "$CONFIG_DIR/$name"
done

link "$DOTFILES_DIR/scripts" "$HOME_DIR/scripts"
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME_DIR/.zshrc"

echo "---"
echo "Done."
