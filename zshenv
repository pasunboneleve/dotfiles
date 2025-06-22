# zshenv is used by all applications, interactive shells or not.
# Hence, be careful about what to include in here, as it may slow down
# all applications needlessly, or even reset things they set.

export PATH=${HOME}/go/bin:${HOME}/.local/bin:${PATH}

export EDITOR="emacsclient -t"
export VISUAL="emacsclient -c"

# set window title
precmd() { echo -en "\e]0;`basename ${PWD}`\a" }

# DO NOT enable ssh-agent in non-interactive terminals, as it will
# change the already set SSH_AUTH_SOCK created by Gnome-keyring and
# confuse applications such as emacs and magit that want to
# communicate with Gnome-keyring.
#
# eval "$(ssh-agent -s)"

DIRENV_ALLOW_NIX=1

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

. "$HOME/.cargo/env"

# >>> coursier install directory >>>
export PATH="$PATH:$HOME/.local/share/coursier/bin"
# <<< coursier install directory <<<

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# make sure emacs is fast with LSP
export LSP_USE_PLISTS=true

# make go happy
export GOPATH=${HOME}/go
export GOBIN=${GOBIN:-$(go env GOPATH)/bin}

# make DBT happy
DBT_PROFILES_DIR=$HOME/.dbt # where $HOME points to your home directory
export DBT_PROFILES_DIR

# add krew to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# make GHC happy and not choke with UTF-8
LANG=en_AU.UTF-8
