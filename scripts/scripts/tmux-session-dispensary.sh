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

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # 1. Append ' *' to active tmux sessions in the listing subshell
    selected=$({
        tmux list-sessions -F "#S *" 2>/dev/null
        fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory "$HOME" | sed "s|^$HOME/||"
    } | grep -v '^$' | fzf --color=bw --height=100% --margin=25%,25%,25%,25% --layout=reverse --info=right --scheme=path --border=sharp --color=base16 --no-scrollbar --gutter=' ')
fi

[[ ! $selected ]] && exit 0

# 2. Strip the trailing ' *' or '*' indicator from the selected string
target="${selected% \*}"
target="${target%\*}"

# 3. Resolve the Session Name
# Check if the cleaned selection IS an existing session first
if tmux has-session -t "$target" 2>/dev/null; then
    selected_name="$target"
else
    # It's a folder, so calculate the full path
    if [[ "$target" == /* ]]; then
        full_path="$target"
    else
        full_path="$HOME/$target"
    fi
    full_path="${full_path%/}"
    
    selected_name=$(basename "$full_path" | tr . _)
    
    # Create the session if it doesn't exist
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

# 4. Switch or Attach
if [[ -z "${TMUX:-}" ]]; then
    tmux attach-session -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
