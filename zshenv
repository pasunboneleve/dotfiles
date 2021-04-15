eval "$(direnv hook zsh)"
eval "$(ssh-agent -s)"

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
