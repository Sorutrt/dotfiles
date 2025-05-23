starship init fish | source

#mise (nodejsなどのバージョン管理ツール)~/.local/share/mise/bin/mise activate fish | source
~/.local/bin/mise activate fish | source

# set -x PATH (npm get prefix -g)/bin $PATH

# opam configuration
source /home/sorutrt/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# add bib-satysfi to PYTHONPATH
set -x PYTHONPATH /home/sorutrt/SATySFi/lib-satysfi/bib-satysfi/pysaty

fish_add_path $HOME/.rbenv/bin:$PATH

# JDK
set -gx JAVA_HOME (readlink -f /usr/bin/javac | sed "s:/bin/javac::")
set -gx PATH $PATH $JAVA_HOME/bin

# pnpm
set -gx PNPM_HOME "/home/sorutrt/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# wsl clipboard
set -gx PATH $HOME/bin /usr/local/bin $PATH

# tex live
set -gx PATH "/usr/local/texlive/2022/bin/x86_64-linux" $PATH

# lazygit alias as gg
alias gg='lazygit'

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

