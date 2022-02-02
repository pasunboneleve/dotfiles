export PATH=${PATH}:${HOME}/.local/bin

export VISUAL="emacsclient -c"

# set window title
precmd() { echo -en "\e]0;`basename ${PWD}`\a" }

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

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
