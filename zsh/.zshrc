# -------------------------------
# 🔧 Zsh Configuration -k4rkie
# -------------------------------
# ~/scripts/pfetch
# 1. Enable color support for prompt
autoload -U colors && colors

# -------------------------------
# 2. History Settings (smart and shared)
# -------------------------------
# File to store command history
HISTFILE=$HOME/.zsh/history/.zsh_history

# Number of commands to save in memory and to file
HISTSIZE=100000
SAVEHIST=100000

# History options for smart saving and sharing across terminals
setopt APPEND_HISTORY             # Append new commands to the history file
setopt SHARE_HISTORY              # Share history across all open shells
setopt INC_APPEND_HISTORY         # Append commands incrementally as you type
setopt HIST_IGNORE_DUPS           # Ignore duplicate entries
setopt HIST_IGNORE_ALL_DUPS       # Remove older duplicates as well
setopt HIST_REDUCE_BLANKS         # Remove extra blanks from history
setopt HIST_VERIFY                # Allow editing of history lines before execution

# -------------------------------
# 3. Auto-Correction (typo fixes)
# -------------------------------
# Enables correction for minor command typos
ENABLE_CORRECTION="true"
setopt CORRECT

# -------------------------------
# 4. Plugin Setup (manual)
# -------------------------------
# Plugins must be cloned manually to ~/.zsh/plugins/
# - zsh-autosuggestions: https://github.com/zsh-users/zsh-autosuggestions
# - zsh-syntax-highlighting: https://github.com/zsh-users/zsh-syntax-highlighting

# Load autosuggestions (suggests commands based on history as you type)
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load syntax highlighting (colors command syntax for clarity)
# IMPORTANT: must be loaded last to work correctly
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------------------------
# 5. Prompt Configuration 
# -------------------------------
# PROMPT=" %~ %k❯ "
# 1. Enable parameter expansion in the prompt
setopt PROMPT_SUBST

# 2. Load vcs_info
autoload -Uz vcs_info
precmd() { vcs_info }

# 3. Format the git output
zstyle ':vcs_info:git:*' formats '(%b) '

# 4. Set the prompt (ensure you use single quotes here)
PROMPT='%~ ${vcs_info_msg_0_}%k❯ '
# -------------------------------
# 6. Aliases
# -------------------------------
alias ls="ls -lh --color=auto -F"
alias la="ls -lha --color=auto -F"

alias nv="nvim"
alias cl="clear"
alias ff="fastfetch"

alias ..="cd .."
alias mv="mv -i"

alias sp="yay -Ss"
alias please='sudo $(fc -ln -1)' 
alias reload="source ~/.zshrc"
alias air='~/go/bin/air'

# -------------------------------
#  PATH variables
# -------------------------------
export PATH="$HOME/.local/bin/scripts:$PATH"
export PATH="$HOME/scripts:$PATH"
export PATH="$HOME/.local/bin/:$PATH"
export PATH="/usr/local/go/bin/:$PATH"

export TERMINAL=kitty
export EDITOR=nvim
export VISUAL=nvim

export PATH="$HOME/.cargo/bin:$PATH"

eval "$(zoxide init zsh)"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Vi mode
bindkey -v

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# bun completions
[ -s "/home/k4rkie/.bun/_bun" ] && source "/home/k4rkie/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=$PATH:$HOME/go/bin

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
