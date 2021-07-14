eval "$(direnv hook zsh)"
eval "$(ssh-agent -s)"

# pyenv
export PATH="$HOME/.local/bin:$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

DIRENV_ALLOW_NIX=1
