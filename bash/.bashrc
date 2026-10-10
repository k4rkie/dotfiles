# -------------------------------
# Bash Configuration - k4rkie
# Simple, no plugins. Converted from .zshrc
# -------------------------------

# Only run for interactive shells
[[ $- != *i* ]] && return

# -------------------------------
# 1. History
# -------------------------------
HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups:ignorespace

shopt -s histappend   # append instead of overwrite (APPEND_HISTORY)
shopt -s checkwinsize # update LINES/COLUMNS after each command
shopt -s cdspell      # closest thing to zsh CORRECT: fix `cd` typos
shopt -s dirspell     # tab-complete with small typos

# Share history across terminals + save immediately:
#  history -a = append current session to file (INC_APPEND)
#  history -n = pull new lines from file (SHARE)
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# -------------------------------
# 2. Prompt
# -------------------------------
# zsh was: green [...] + cyan $USER + pink @ + yellow path + green ]
PS1='\[\e[38;2;153;195;124m\][\[\e[0m\]\[\e[38;2;138;181;190m\]\u\[\e[0m\]\[\e[38;2;190;113;128m\]@\[\e[0m\]\[\e[38;2;239;190;119m\]\w\[\e[0m\]\[\e[38;2;153;195;124m\]]\[\e[0m\]> '

set -o emacs

# -------------------------------
# 3. Aliases
# -------------------------------
alias ls="eza -lh --icons=always --git"
alias la="eza -lha --icons=always --git"

alias vi="nvim"
alias reload="source ~/.bashrc"
alias tsd="tmux-session-dispensary.sh"

# -------------------------------
# 4. Env + PATH 
# -------------------------------
export TERMINAL=foot
export EDITOR=nvim

export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.config/nvm"

export PATH="$HOME/.npm-global/bin:$BUN_INSTALL/bin:$HOME/.cargo/bin:$HOME/.opencode/bin:$HOME/.local/bin:$HOME/scripts:/usr/local/go/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"

# -------------------------------
# 5. Tools
# -------------------------------

# zoxide
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# yazi "open and cd" helper 
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# -------------------------------
# 6. Lazy-loaded nvm (kept from zshrc)
# -------------------------------
_lazy_load_nvm() {
	unset -f nvm node npm npx
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

nvm()  { _lazy_load_nvm; nvm "$@"; }
node() { _lazy_load_nvm; node "$@"; }
npm()  { _lazy_load_nvm; npm "$@"; }
npx()  { _lazy_load_nvm; npx "$@"; }

# bun completions (fast, keep eager)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# fzf: Ctrl-R = history, Ctrl-T = files, Alt-C = cd
[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
