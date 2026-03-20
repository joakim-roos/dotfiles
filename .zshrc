# Completion
autoload -Uz compinit && compinit
zmodload zsh/complist
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
setopt MENU_COMPLETE

# Escape cancels completion menu
KEYTIMEOUT=10
bindkey -M menuselect '\e' send-break

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Claude Code aliases
alias ccc="claude --dangerously-skip-permissions"
alias ccn="claude"

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."

# Git aliases
alias gp="git push"
alias gpr="git pull --rebase"
alias gs="git status"
alias glo="git log --oneline"
alias gc="git commit"
alias ga="git add"
alias c3000="lsof -ti :3000 | xargs kill"

# Manual beads backup to git (overrides BD_BACKUP_GIT_PUSH=false from .zshenv)
alias bd-backup-push='BD_BACKUP_GIT_PUSH=true bd backup --force'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/Users/jr/.bun/_bun" ] && source "/Users/jr/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# GPG
 export GPG_TTY=$(tty)
