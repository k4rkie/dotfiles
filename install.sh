#!/usr/bin/env bash

# Super simple install script to force-symlink dotfiles
# WARNING: This will overwrite existing configurations!

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "Creating symlinks in $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

# Core config directories
configs=(
    foot hypr mango mpv nvim quickshell rmpc rofi 
    swayosd wallust waybar yazi zathura zed
)

for config in "${configs[@]}"; do
    # Remove existing directory/file if it exists to ensure a clean symlink
    rm -rf "$CONFIG_DIR/$config"
    ln -sfn "$DOTFILES_DIR/$config" "$CONFIG_DIR/$config"
    echo "Linked ~/.config/$config"
done

echo "Creating home directory symlinks..."

# Scripts
rm -rf "$HOME/scripts"
ln -sfn "$DOTFILES_DIR/scripts" "$HOME/scripts"
echo "Linked ~/scripts"

# Zsh
rm -f "$HOME/.zshrc"
ln -sfn "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
echo "Linked ~/.zshrc"

# Tmux
rm -f "$HOME/.tmux.conf"
ln -sfn "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
echo "Linked ~/.tmux.conf"

echo "Installation complete! Enjoy your rice."
