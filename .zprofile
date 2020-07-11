case ${OSTYPE} in
  darwin*)
    # mac
    # don't read /etc/profile where path_helper is called
    # prevent overwrite of environment variables
    # https://takuya-1st.hatenablog.jp/entry/2013/12/14/040814
    # https://memo.sugyan.com/entry/20151211/1449833480
    setopt no_global_rcs
    ;;
  linux*)
    # linux
    ;;
esac

# XDG Base Direcotry Specification
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME=$HOME/.config

typeset -U path
export path=(
  /usr/local/bin
  /usr/sbin
  /sbin
  $path
)

export EDITOR=nvim

# export FPATH=~/.ghq/github.com/suzuki-shunsuke/zsh.conf:$FPATH
# export FPATH="$HOME/.ghq/github.com/suzuki-shunsuke/zsh.conf/functions:${FPATH}"
# https://github.com/motemen/ghq
export GHQ_ROOT=~/repos/src

GNUMANPATH=/usr/local/opt/findutils/libexec/gnuman
if [ -d "$GNUMANPATH" ]; then
  export MANPATH=$GNUMANPATH:$MANPATH
fi

if builtin command -v direnv > /dev/null; then
  export path=(
    $(brew --prefix coreutils)/libexec/gnubin
    /usr/local/opt/findutils/libexec/gnubin
    $path
  )
fi

# export GOPATH=$HOME/go:/usr/local/opt/go/libexec:$GOPATH

export HISTSIZE=1000
export HISTFILE=$HOME/.zsh_history
export SAVEHIST=100000

export RBENV_ROOT=$HOME/.rbenv

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_SHELL=zsh

export path=(
  ${KREW_ROOT:-$HOME/.krew}/bin
  $HOME/.akoi/bin
  $HOME/bin
  $RBENV_ROOT/bin
  $PYENV_ROOT/bin
  $PYENV_ROOT/shims
  $HOME/go/bin
  # rust
  $HOME/.cargo/bin
  $HOME/repos/bin
  # https://github.com/hokaccha/nodebrew
  $HOME/.nodebrew/current/bin
  /usr/local/go/bin
  # Use openssl instead of LibreSSL
  # https://qiita.com/moroi/items/53d60d1d6885795a0f6f
  # https://qiita.com/kinichiro/items/3108e950b056963c33ad
  /usr/local/Cellar/openssl/1.0.2s/bin
  # https://qiita.com/eumesy/items/3bb39fc783c8d4863c5f
  # GNU sed
  /usr/local/opt/gnu-sed/libexec/gnubin
  # GNU grep; brew install grep
  /usr/local/opt/grep/libexec/gnubin
  $path
)

if [ -d $RBENV_ROOT ]; then
  eval "$(rbenv init -)"
fi

# SSH Agent Configuration
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval `ssh-agent` > /dev/null
  export SSH_AUTH_SOCK=$SSH_AUTH_SOCK
fi

# https://virtualenvwrapper.readthedocs.io/en/latest/
export WORKON_HOME=$HOME/.virtualenvs

# https://github.com/zplug/zplug
export ZPLUG_HOME=$HOME/.zplug
unset ZPLUG_SHALLOW

if [ -d $PYENV_ROOT ]; then
  eval "$(pyenv init -)"
fi
if which pyenv > /dev/null && [ -d $(pyenv root)/plugins/pyenv-virtualenv ]; then
  eval "$(pyenv virtualenv-init -)"
fi

export GOROOT=$(go env GOROOT)

# load this machine specific configuration
[ -f $HOME/zsh.d/zprofile ] && source $HOME/zsh.d/zprofile
[ -f $HOME/zsh.d/zprofile_secret ] && source $HOME/zsh.d/zprofile_secret

export PATH="$HOME/.cargo/bin:$PATH"
