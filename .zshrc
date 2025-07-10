##############################
## Executables & Programs
##############################
# Local Bin
export PATH=~/.local/bin:$PATH

# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Go
export PATH=$PATH:$(go env GOPATH)/bin

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Pnpm
export PNPM_HOME="/Users/dan/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Bun
[ -s "/Users/dan/.bun/_bun" ] && source "/Users/dan/.bun/_bun"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Starship
eval "$(starship init zsh)"

# FZF
source <(fzf --zsh)

##############################
## Antidote (Plugin Manager)
##############################
active="${${(%):-%N}:A}"
plugins_file="$HOME/.cache/antidote/zsh_plugins.zsh"

if [[ ! "$plugins_file" -nt "$active" ]]; then
  source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
  mkdir -p "${plugins_file:h}"
  antidote bundle <<-plugins >| "$plugins_file"
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-history-substring-search
    MichaelAquilina/zsh-autoswitch-virtualenv
plugins
fi

source "$plugins_file"

##############################
## Config
##############################
export EDITOR="nvim"
alias ls="gls --color --group-directories-first"
alias la="gls -lah --color --group-directories-first"
alias gs="lazygit"
alias oc="opencode"
alias python="python3"

