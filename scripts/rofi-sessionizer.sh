#!/usr/bin/env bash

DIRS=(
    "$HOME"
    "$HOME/learn"
    "$HOME/dev"
    "$HOME/dev/go"
    "$HOME/dev/Feriyo"
    "$HOME/dev/C"
    "$HOME/dev/C/graphics"
    "$HOME/dev/JS"
    "$HOME/dev/Rust"
    "$HOME/dotfiles"
)

# 1. Get all folders from your DIRS
folder_list=$(fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory "$HOME" | sed "s|^$HOME/||")

# 2. Get all active tmux sessions and append ' *' to their names
session_list=$(tmux list-sessions -F "#S *" 2>/dev/null)

# 3. Combine them, remove duplicates, and pipe to Rofi
selected=$(printf "%s\n%s" "$session_list" "$folder_list" | grep -v '^$' | rofi -dmenu -i -p " 󱫋 Session")

[[ ! $selected ]] && exit 0

# Strip trailing asterisk and spaces to resolve original session/folder name
target="${selected% \*}"
target="${target%\*}"

# 4. Logic: Is it a session or a folder?
if tmux has-session -t "$target" 2>/dev/null; then
    selected_name="$target"
else
    # It's a folder, calculate the full path
    if [[ "$target" == /* ]]; then
        full_path="$target"
    else
        full_path="$HOME/$target"
    fi
    full_path="${full_path%/}"
    
    selected_name=$(basename "$full_path" | tr . _)
    
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$full_path"

        if [[ -f "$full_path/.tmux-windows" ]]; then
            while IFS= read -r line; do
                [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
                if [[ "$line" == *:* ]]; then
                    win_name="${line%%:*}"
                    win_dir="${line#*:}"
                    win_dir="${win_dir# }"
                else
                    win_name="$line"
                    win_dir="."
                fi
                [[ "$win_dir" == "." ]] && win_path="$full_path" || win_path="$full_path/$win_dir"
                tmux new-window -t "$selected_name" -n "$win_name" -c "$win_path"
            done < "$full_path/.tmux-windows"
            tmux kill-window -t "$selected_name:1"
        fi
    fi
fi

# 5. Launch emacsclient

# kitty
# kitty --detach tmux attach-session -t "$selected_name" 

# foot
footclient tmux attach-session -t "$selected_name" &
