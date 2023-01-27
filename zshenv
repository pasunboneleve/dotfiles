export PATH=${PATH}:${HOME}/.local/bin

export EDITOR="emacsclient -t"
export VISUAL="emacsclient -c"

# necessary to use tramp-mode
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# set window title
precmd() { echo -en "\e]0;`basename ${PWD}`\a" }

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

# eval "$(direnv hook zsh)"
# eval "$(ssh-agent -s)"

DIRENV_ALLOW_NIX=1

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

if [ -f $HOME/.secret_env ]; then source ~/.secret_env; fi
. "$HOME/.cargo/env"

# >>> coursier install directory >>>
export PATH="$PATH:$HOME/.local/share/coursier/bin"
# <<< coursier install directory <<<

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
