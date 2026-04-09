#!/bin/bash

DIRS=(
    "$HOME"
    "$HOME/dev"
    "$HOME/dev/Feriyo"
    "$HOME/dev/C"
    "$HOME/dev/JS"
    "$HOME/dotfiles/"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/skim-themes.sh"

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # We use a subshell ( ... ) to collect output from both commands
    # This is more robust for Skim/Fzf piping
    selected=$({
        # 1. Get folders from disk
        fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory "$HOME" | sed "s|^$HOME/||"
        
        # 2. Get active tmux sessions (only the names)
        # 2>/dev/null ensures it doesn't crash if no sessions exist
        tmux list-sessions -F "#S" 2>/dev/null
    } | sort -u | sk "${SKIM_THEME_SESSION[@]}")
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
