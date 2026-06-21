# zshrc is only used by interactive shells, so it is safe to
# set environment variables here that shouldn't be used by
# non-interactive programs and applications.

# Disable flow control, so the terminal doesn't freeze
# when we press ctrl-s. Without it flow can be regained
# by pressing ctrl-q.
stty ixany

# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
setopt hist_ignore_dups
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust \
    zsh-users/zsh-completions \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-history-substring-search \
    agkozak/zsh-z

### End of Zinit's installer chunk

### bind keys for history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

### bind Ctr-arrow keys for emacs-like word skip
bindkey -M emacs "^[[1;5C" forward-word
bindkey -M emacs "^[[1;5D" backward-word

### bind Ctrl-delete keys for emacs-like kill word
bindkey -M emacs '^[[3;5~' kill-word
bindkey -M emacs '^H' backward-kill-word

### starship
export STARSHIP_CONFIG=~/.config/dotfiles/starship.toml
zinit ice as"command" from"gh-r" \
      atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
      atpull"%atclone" src"init.zsh"
zinit light starship/starship

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pipx
autoload -Uz compinit
compinit
autoload -Uz bashcompinit
bashcompinit
if command -v register-python-argcomplete >/dev/null 2>&1; then
  eval "$(register-python-argcomplete pipx)"
fi

# zsh plugins shipped by the system package manager live under different
# prefixes: Fedora's dnf uses /usr/share, Homebrew uses $(brew --prefix)/share.
# HOMEBREW_PREFIX is exported by `brew shellenv` in zshenv on macOS.
if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  _zsh_plugin_prefix="$HOMEBREW_PREFIX/share"
else
  _zsh_plugin_prefix="/usr/share"
fi

# autocompletion
# zinit light marlonrichert/zsh-autocomplete
[[ -r "$_zsh_plugin_prefix/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  zinit snippet "$_zsh_plugin_prefix/zsh-autosuggestions/zsh-autosuggestions.zsh"

## highlight syntax (must be last thing in zshrc)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
[[ -r "$_zsh_plugin_prefix/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$_zsh_plugin_prefix/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

## direnv
eval "$(direnv hook zsh)"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# open markdown files as html in chrome
render-markdown () {
  id=$(uuidgen | cut -c -8)
  today=$(date)
  filename=$1:t:r
  filepath=/tmp/md-$id.html
  html_body=$(
    pandoc \
    --standalone \
    --metadata date-meta=$today \
    --metadata date=$today \
    --metadata title=$filename \
    --template \
    ~/.config/dotfiles/template.html $1
  )
  (echo $html_body) > $filepath
  google-chrome $filepath
}

# necessary to use tramp-mode
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# nvm
export NVM_DIR="$HOME/.nvm"

# # pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

# plugin=(
#   pyenv
# )

# eval "$(pyenv init --path)"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

if [ -f "$HOME/.secret_env" ]; then source "$HOME/.secret_env"; fi

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# simplify gcloud red tape

 gcloud-use() {
    local account="$1"
    local project="$2"

    if [ -z "$account" ] || [ -z "$project" ]; then
      echo "usage: gcloud-use <account> <project-id>"
      return 1
    fi

    gcloud auth login "$account" || return 1
    gcloud config set account "$account" || return 1
    gcloud config set project "$project" || return 1
    gcloud auth application-default login || return 1
    gcloud auth application-default set-quota-project "$project" || return 1

    echo
    echo "Active gcloud account: $(gcloud config get-value account 2>/dev/null)"
    echo "Active gcloud project: $(gcloud config get-value project 2>/dev/null)"
  }


# Load Angular CLI autocompletion.
if command -v ng >/dev/null 2>&1; then
  source <(ng completion script)
fi
export PATH="$HOME/.bhc/bin:$PATH"
export LIBRARY_PATH="$HOME/.bhc/lib:$LIBRARY_PATH"


# Added by Antigravity CLI installer
export PATH="/home/dmvianna/.local/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section
