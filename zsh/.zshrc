# Created by newuser for 5.9
# ---- starship ----
eval "$(starship init zsh)"

# ---- zsh plugins ----
source $(nix eval --raw nixpkgs#zsh-autosuggestions)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(nix eval --raw nixpkgs#zsh-syntax-highlighting)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- history ----
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt hist_ignore_dups
setopt share_history

# ---- completion ----
autoload -Uz compinit
compinit

# ---- colorized ls ----
export CLICOLOR=1
eval "$(dircolors ~/.dircolors)"
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'

