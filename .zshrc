# Custom shell configuration loaded by the Hjem integration.

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
mkdir -p "$ZSH_CACHE_DIR/completions"
chmod u+w "$ZSH_CACHE_DIR"/completions/*(.N) 2>/dev/null || true

fpath=("$ZSH_CACHE_DIR/completions" $fpath)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

PROMPT="%B%F{magenta}#%f%b "
