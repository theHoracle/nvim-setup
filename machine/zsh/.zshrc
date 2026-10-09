
# Development shell
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
export EDITOR=nvim
export VISUAL=nvim

# Shell completions
autoload -Uz compinit
compinit

# Use Neovim for Vim commands
alias vim=nvim
alias vi=nvim

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  ":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Colorful development prompt
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS SHARE_HISTORY

autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr ' +'
zstyle ':vcs_info:git:*' unstagedstr ' *'
zstyle ':vcs_info:git:*' formats ' %F{#bb9af7} %b%f%F{#e0af68}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{#bb9af7} %b (%a)%f%F{#e0af68}%u%c%f'
_horacle_prompt_precmd() { vcs_info }
add-zsh-hook precmd _horacle_prompt_precmd
setopt PROMPT_SUBST
PROMPT=$'\n%F{#7aa2f7} %B%~%b%f${vcs_info_msg_0_}\n%(?.%F{#9ece6a}.%F{#f7768e})❯%f '
RPROMPT=''
