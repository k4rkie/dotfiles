#!/bin/bash

DIRS=(
    "$HOME"
    "$HOME/learn"
    "$HOME/k4rkie/CS"
    "$HOME/dev"
    "$HOME/dev/go"
    "$HOME/dev/Feriyo"
    "$HOME/dev/C"
    "$HOME/dev/C/graphics"
    "$HOME/dev/JS"
    "$HOME/dotfiles/"
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$({
        tmux list-sessions -F "#S" 2>/dev/null
        fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory "$HOME" | sed "s|^$HOME/||"
    } | grep -v '^$' | fzf --color=bw --height=70% --margin=10%,20%,20%,20% --layout=reverse --info=hidden --scheme=path)
fi

[[ ! $selected ]] && exit 0

# 4. Resolve the Session Name
# Check if the selection IS an existing session first
if tmux has-session -t "$selected" 2>/dev/null; then
    selected_name="$selected"
else
    # It's a folder, so calculate the full path
    # If the user selected a subfolder, we ensure it starts with $HOME
    if [[ "$selected" == /* ]]; then
        full_path="$selected"
    else
        full_path="$HOME/$selected"
    fi
    
    selected_name=$(basename "$full_path" | tr . _)
    
    # Create the session if it doesn't exist
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$full_path"
        tmux select-window -t "$selected_name:1"
    fi
fi

# 5. Switch or Attach
if [[ -z "${TMUX:-}" ]]; then
    tmux attach-session -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
