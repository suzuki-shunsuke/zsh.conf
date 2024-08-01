# uncomment out when profiling
# export ZSH_PROFILING=1
if [ -n "$ZSH_PROFILING" ]; then
  zmodload zsh/zprof && zprof
fi

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
export XDG_CONFIG_HOME="$HOME/.config"

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

brew_path=/opt/homebrew/bin/brew
if [ -f "$brew_path" ]; then
  eval "$("$brew_path" shellenv)"
fi

add_manpath() {
  for dir in "$@"; do
    if [ -d "$dir" ]; then
      export MANPATH="$dir:$MANPATH"
    fi
  done
}

if command -v brew > /dev/null; then
  export path=(
    "$(brew --prefix coreutils)/libexec/gnubin"(N-/)
    "$(brew --prefix findutils)/libexec/gnubin"(N-/)
    "$(brew --prefix gnu-sed)/libexec/gnubin"(N-/)
    "$(brew --prefix grep)/libexec/gnubin"(N-/)
    $path
  )

  add_manpath "$(brew --prefix coreutils)/libexec/gnuman" "$(brew --prefix findutils)/libexec/gnuman"

  fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
fi

export HISTSIZE=1000
export HISTFILE="$HOME/.zsh_history"
export SAVEHIST=100000

export RBENV_ROOT="$HOME/.rbenv"

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_SHELL=zsh

export path=(
  $HOME/google-cloud-sdk/bin(N-/)
  ${KREW_ROOT:-$HOME/.krew}/bin(N-/)
  $HOME/bin(N-/)
  $RBENV_ROOT/bin(N-/)
  $PYENV_ROOT/bin(N-/)
  $PYENV_ROOT/shims(N-/)
  $HOME/go/bin(N-/)
  # rust
  $HOME/.cargo/bin(N-/)
  # https://github.com/hokaccha/nodebrew
  # $HOME/.nodebrew/current/bin
  # Use openssl instead of LibreSSL
  # https://qiita.com/moroi/items/53d60d1d6885795a0f6f
  # https://qiita.com/kinichiro/items/3108e950b056963c33ad
  # /usr/local/Cellar/openssl/1.0.2s/bin(N-/)
  "${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin"
  $path
)

if [ -d "$RBENV_ROOT" ]; then
  eval "$(rbenv init -)"
fi

# SSH Agent Configuration
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent) > /dev/null
  export "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
fi

# https://virtualenvwrapper.readthedocs.io/en/latest/
export "WORKON_HOME=$HOME/.virtualenvs"

# https://github.com/zplug/zplug
# export "ZPLUG_HOME=$HOME/.zplug"
# unset ZPLUG_SHALLOW

if [ -d "$PYENV_ROOT" ]; then
  eval "$(pyenv init -)"
fi
if command -v pyenv > /dev/null && [ -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
  eval "$(pyenv virtualenv-init -)"
fi

# load this machine specific configuration
# [ -f "$HOME/zsh.d/zprofile" ] && source "$HOME/zsh.d/zprofile"
# [ -f "$HOME/zsh.d/zprofile_secret" ] && source "$HOME/zsh.d/zprofile_secret"

export AQUA_GLOBAL_CONFIG="${AQUA_GLOBAL_CONFIG:-}:${$GHQ_ROOT}/github.com/aquaproj/aqua-registry/aqua-all.yaml"

# autoload -Uz compinit
autoload -Uz colors
autoload -U compinit
compinit -u

# create the pull request based on the current branch
_git-pr() {
  local branch
  branch=$(git-current-branch)
  git push origin "$branch" || return 1
  hub pull-request -o -h "$GIT_USERNAME:$branch"
}

git-browse() {
  local remote
  remote=$(git config branch.master.remote)
  test "$remote" != "" || return 1
  if [ $# -eq 1 ]; then
    remote=$1
  fi
  open "$(git config remote.${remote}.url)" &
}

nx() {
  npm --silent run $1 -- ${@:2}
}

replace() {
  ag -l --hidden "$1" | xargs -n 1 gsed -i "s/$1/$2/g"
}

git_replace() {
  git grep -l "$1" | xargs -n 1 gsed -i "s/$1/$2/g"
}

clone_pr() {
  read "remote?remote (ex. origin, upstream): "
  if [ "$remote" = "" ]; then
    return 0
  fi
  read "pr_id?pull request id: "
  if [ "$pr_id" = "" ]; then
    return 0
  fi
  read "branch_name?branch name: "
  if [ "$branch_name" = "" ]; then
    return 0
  fi
  echo "+ git fetch $remote pull/$pr_id/head:$branch_name"
  git fetch "$remote" "pull/$pr_id/head:$branch_name"
}

alias sudo="sudo -E"
alias ls="gls --color=auto"
alias npm="npm --silent"
alias tf="terraform"
alias k="kubectl"
alias cx="cmdx"

bindkey -v

# 
# zmv
autoload -Uz zmv
# 
# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# if [ -f ~/.zplug/init.zsh ]; then
#     source ~/.zplug/init.zsh
# fi

# zstyle :zplug:tag depth 1

# if [ $ZPLUG_HOME ]; then
#     # zplug "plugins/git", from:oh-my-zsh, if:"(( $+commands[git] ))"
#     # zplug "plugins/command-not-found", from:oh-my-zsh
#     zplug "zsh-users/zsh-completions"
#     # zplug "zsh-users/zsh-syntax-highlighting", defer:2
#     # zplug "mollifier/cd-gitroot"
#     
#     # load this machine specific configuration
#     [ -f "$HOME/zsh.d/zplug" ] && source "$HOME/zsh.d/zplug"
# 
#     zplug "mollifier/anyframe", defer:2
#     zplug "mafredri/zsh-async", on:sindresorhus/pure
#     zplug "sindresorhus/pure", use:pure.zsh, defer:3
#     zplug "lukechilds/zsh-nvm"
# 
# # 
# #     if ! zplug check --verbose; then
# #         printf "Install? [y/N]: "
# #         if read -q; then
# #             echo; zplug install
# #         fi
# #     fi
# # 
#     zplug load  # --verbose
# fi

# direnv
# https://github.com/direnv/direnv
if builtin command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

alias dps='docker-compose ps'
alias dup='docker-compose up -d'
alias dstp='docker-compose stop'
alias drst='docker-compose restart'
alias dexc='docker-compose exec'
alias drm='docker-compose rm'
alias dbuild='docker build -t'
alias dimg='docker images'
alias dpush='docker push'
# git
alias ga='git add'
alias gap='git add -p'
alias gc='git commit'
alias gca='git commit --amend'
alias gch='git commit --amend -C HEAD'
alias gsta='git stash'
alias gstau='git stash -u'
alias gstaa='git stash --apply'
alias gcb='git_current_branch'
alias gp='git push'
alias gpp='git push origin $(git_current_branch)'
alias gppf='git push origin $(git_current_branch) --force'
alias gll='git pull origin $(git_current_branch)'
alias gf='git fetch'
alias gm='git merge'
alias gmom='git merge origin/master'
alias gmum='git merge upstream/master'
alias gst='git status'
alias glog='git log'
alias gtaga='git tag -a'
alias gdt='git difftool'
alias gdtc='git difftool --cached'
alias gcm='git checkout master'
alias gco='git checkout'

git-current-branch() {
    git branch | grep "^\* " | sed -e "s/^\* \(.*\)/\1/"
}

# hub
# https://hub.github.com/
if builtin command -v hub > /dev/null; then
    alias git=hub
    # eval "$(hub alias -s)"
fi

# vim
if builtin command -v nvim > /dev/null; then
    alias vi="nvim"
    alias vimdiff='nvim -d -u ~/.config/nvim/init.vim'
    alias vdf='nvim -d -u ~/.config/nvim/init.vim'
fi

# profiling
if [ -n "$ZSH_PROFILING" ]; then
  if type zprof > /dev/null 2>&1; then
    zprof | less
  fi
fi

# https://github.com/sindresorhus/pure#my-preprompt-is-missing-when-i-clear-the-screen-with-ctrll 
zle -N clear-screen prompt_pure_clear_screen
# fzf
# https://github.com/junegunn/fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
# anyframe
# https://github.com/mollifier/anyframe
bindkey '^xb' anyframe-widget-cdr
bindkey '^x^b' anyframe-widget-checkout-git-branch
bindkey '^xg' anyframe-widget-cd-ghq-repository
bindkey '^xf' anyframe-widget-insert-filename
bindkey '^xr' anyframe-widget-execute-history
# write after fzf completion configurations because this configuration conflict with them
bindkey '^r' anyframe-widget-execute-history
bindkey '^xp' anyframe-widget-put-history

# https://github.com/gsamokovarov/jump
eval "$(jump shell)"

# kube-ps1
# https://github.com/jonmosco/kube-ps1
source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1
kubeoff

# load this machine specific configuration
[ -f "$HOME/zsh.d/zshrc" ] && source "$HOME/zsh.d/zshrc"

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/shunsuke-suzuki/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/shunsuke-suzuki/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/shunsuke-suzuki/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/shunsuke-suzuki/google-cloud-sdk/completion.zsh.inc'; fi

URFAVE_CLI_COMPLETION="$HOME/repos/src/github.com/urfave/cli/autocomplete/zsh_autocomplete"
if [ -f "$URFAVE_CLI_COMPLETION" ]; then
  PROG=cmdx
  source "$URFAVE_CLI_COMPLETION"
fi
