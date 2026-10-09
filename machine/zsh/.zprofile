
# Development tools
eval "$(/opt/homebrew/bin/brew shellenv)"
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)
export PATH
