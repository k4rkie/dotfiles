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
setopt PROMPT_SUBST

# 2. Load vcs_info
autoload -Uz vcs_info
precmd() { vcs_info }

# 3. Format the git output
zstyle ':vcs_info:git:*' formats '(󰘬 %b) '

# 4. Set the prompt (ensure you use single quotes here)
PROMPT='[%F{#7D718F}%~%f] ${vcs_info_msg_0_}%k$ '

# -------------------------------
# 6. Aliases
# -------------------------------
alias ls="eza -lha  --icons=always --git"

alias vi="nvim"
alias reload="source ~/.zshrc"

# -------------------------------
#  PATH variables
# -------------------------------
export PATH="$HOME/.local/bin/:$PATH"

export PATH="/usr/local/go/bin/:$PATH"
export PATH=$PATH:$HOME/go/bin

export TERMINAL=foot
export EDITOR=nvim

export PATH="$HOME/.cargo/bin:$PATH"

eval "$(zoxide init zsh)"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# lazy load nvm so terminal opens instantly
export NVM_DIR="$HOME/.config/nvm"
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}
npm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}
npx() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npx "$@"
}

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# opencode
export PATH=/home/k4rkie/.opencode/bin:$PATH

# fzf bindings (fast load)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Added by Antigravity CLI installer
export PATH="/home/k4rkie/.local/bin:$PATH"

# npm global prefix
export PATH="$HOME/.npm-global/bin:$PATH"
