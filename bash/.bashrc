# Only run for interactive shells
[[ $- != *i* ]] && return

# History
HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups:ignorespace

shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell      
shopt -s dirspell

# Share history across terminals + save immediately:
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# Prompt
style-prompt() {
  local rst=$'\e[0m'
  local bold=$'\e[1m'
  local green=$'\e[32m'
  local blue=$'\e[36m'
  local red=$'\e[31m'
  local yellow=$'\e[33m'

  # prompt = [user@pwd]>

  # Add [
  PS1='\['$green'\][\['$rst'\]'

  # Add user
  PS1+='\['$blue'\]\u\['$rst'\]'

  # Add @
  PS1+='\['$red'\]@\['$rst'\]'

  # Add pwd
  PS1+='\['$yellow'\]\w\['$rst'\]'

  # Add ]>
  PS1+='\['$green'\]]\['$rst'\]󰅂 '
}
style-prompt

# Emacs binds
set -o vi

# Aliases
alias ls="eza -lh"
alias la="eza -lhA"

alias ..="cd .."

alias vi="nvim"
alias reload="source ~/.bashrc"
alias tsd="tmux-session-dispensary.sh"

alias rm="rm -i"

alias hl="rg --passthru"

alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gl="git log"

# Env + PATH 
export TERMINAL=foot
export EDITOR=nvim
export PAGER=less
export MANPAGER=less

export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.config/nvm"
export PATH="$PATH:$BUN_INSTALL/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/scripts:$HOME/go/bin"
export BAT_THEME="base16"

## Enable colors in Less By:YSAP
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;33;44m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;1;32m'
export LESS_TERMCAP_mr=$'\e[7m'
export LESS_TERMCAP_mh=$'\e[2m'
export LESS_TERMCAP_ZN=$'\e[74m'
export LESS_TERMCAP_ZV=$'\e[75m'
export LESS_TERMCAP_ZO=$'\e[73m'
export LESS_TERMCAP_ZW=$'\e[75m'

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

# nvm (lazy-loaded)
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

#functions
mann() {
  man $1 | bat -l man --style=plain
}

# Added by Antigravity CLI installer
export PATH="/home/k4rkie/.local/bin:$PATH"
