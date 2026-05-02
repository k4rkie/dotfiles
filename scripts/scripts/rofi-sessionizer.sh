#!/bin/bash

DIRS=(
    "$HOME"
    "$HOME/dev"
    "$HOME/dev/go"
    "$HOME/dev/Feriyo"
    "$HOME/dev/C"
    "$HOME/dev/C/graphics"
    "$HOME/dev/JS"
    "$HOME/dev/Rust/"
    "$HOME/dotfiles/"
    "$HOME/Braincache/"
)

# 1. Get all folders from your DIRS
folder_list=$(fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory "$HOME" | sed "s|^$HOME/||")

# 2. Get all currently active tmux sessions
session_list=$(tmux list-sessions -F "#S" 2>/dev/null)

# 3. Combine them, remove duplicates, and pipe to Rofi
selected=$(printf "%s\n%s" "$folder_list" "$session_list" | sort -u | rofi -dmenu -i -p "󱫋 Session")

[[ ! $selected ]] && exit 0

# 4. Logic: Is it a session or a folder?
# Check if it's an existing session first
if tmux has-session -t "$selected" 2>/dev/null; then
    selected_name="$selected"
    # We don't need to 'create' anything, just attach
else
    # It's a folder, so do the usual path logic
    full_path="$HOME/$selected"
    selected_name=$(basename "$full_path" | tr . _)
    
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$full_path"
    fi
fi

# 5. Launch Kitty
kitty --detach tmux attach-session -t "$selected_name"
