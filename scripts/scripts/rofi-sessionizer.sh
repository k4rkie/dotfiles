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
    # Existing tmux session: attach via Kitty
    kitty --detach tmux attach-session -t "$target"
else
    # It's a folder: open it in Zed
    if [[ "$target" == /* ]]; then
        full_path="$target"
    else
        full_path="$HOME/$target"
    fi
    full_path="${full_path%/}"

    (cd "$full_path" && zeditor .) & disown
fi
