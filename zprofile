{% from 'rc-fusion/macros/local.j2' import local %}

case ${OSTYPE} in
  darwin*)
    # mac
    # don't read /etc/profile where path_helper is called
    # prevent overwrite of environment variables
    setopt no_global_rcs
    ;;
  linux*)
    # linux
    ;;
esac

# XDG Base Direcotry Specification
export XDG_CONFIG_HOME=$HOME/.config

typeset -U path
path=(
    /usr/local/bin
    /usr/sbin
    /sbin
    $HOME/bin
    $path
)
export PATH

export EDITOR=nvim

# export FPATH=~/.ghq/github.com/suzuki-shunsuke/zsh.conf:$FPATH
# export FPATH="$HOME/.ghq/github.com/suzuki-shunsuke/zsh.conf/functions:${FPATH}"

{{ local([
  "secrets/zprofile",
  "**/zprofile", "!zprofile",
  "!android-sdk/zprofile", "!dckrm/zprofile",
  "!dirssh/zprofile", "!google-cloud-sdk/zprofile",
  "!heroku/zprofile", "!vim-virtualenv/zprofile",
  "pyenv/zprofile", "pyenv-virtualenv/zprofile"]) }}
