# zshrc is only used by interactive shells, so it is safe to
# set environment variables here that shouldn't be used by
# non-interactive programs and applications.

# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pipx
autoload -Uz compinit
compinit
autoload -Uz bashcompinit
bashcompinit
eval "$(register-python-argcomplete pipx)"

# autocompletion
# zinit light marlonrichert/zsh-autocomplete
zinit snippet /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

## highlight syntax (must be last thing in zshrc)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## direnv
eval "$(direnv hook zsh)"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

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

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

# nvm
export NVM_DIR="$HOME/.nvm"

plugin=(
  pyenv
)

eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

if [ -f $HOME/.secret_env ]; then source ~/.secret_env; fi
