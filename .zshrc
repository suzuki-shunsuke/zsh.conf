fpath=($(brew --prefix)/share/zsh/site-functions $fpath)

# autoload -Uz compinit
autoload -Uz colors
# compinit -u

# create the pull request based on the current branch
_git-pr() {
  local branch=`git-current-branch`
  git push origin $branch || return 1
  git pull-request -o -h $GIT_USERNAME:$branch
}

git-browse() {
  local remote=`git config branch.master.remote`
  test "$remote" != "" || return 1
  if [ $# -eq 1 ]; then
    remote=$1
  fi
  open `git config remote.${remote}.url` &
}

nx() {
  npm --silent run $1 -- ${@:2}
}

replace() {
  ag -l --hidden "$1" | xargs -n 1 gsed -i "s/$1/$2/g"
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
  git fetch $remote pull/$pr_id/head:$branch_name
}

dctag() {
  if [ $# -eq 0 -o "$1" = "help" -o "$1" = "--help" -o "$1" = "-help" ]; then
    cat << EOS
List Docker image tags
Usage: $ dctag <image name>
ex. $ dctag alpine
EOS
    return 0
  fi
  if [ $# -ne 1 ]; then
    cat << EOS >&2
Too many arguments
For help, please run 'dctag help'
EOS
    return 1
  fi
  reg tags "$1" | grep ".*\..*" | sort -rV
}

alias sudo="sudo -E"
alias ls="gls --color=auto"
alias npm="npm --silent"
alias tf="terraform"

bindkey -v

# 
# zmv
autoload -Uz zmv
# 
# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

if [ -f ~/.zplug/init.zsh ]; then
    source ~/.zplug/init.zsh
fi

zstyle :zplug:tag depth 1

if [ $ZPLUG_HOME ]; then
    # zplug "plugins/git", from:oh-my-zsh, if:"(( $+commands[git] ))"
    # zplug "plugins/command-not-found", from:oh-my-zsh
    zplug "zsh-users/zsh-completions"
    # zplug "zsh-users/zsh-syntax-highlighting", defer:2
    # zplug "mollifier/cd-gitroot"
    
    # load this machine specific configuration
    [ -f $HOME/zsh.d/zplug ] && source $HOME/zsh.d/zplug

    zplug "mollifier/anyframe", defer:2
    zplug "mafredri/zsh-async", on:sindresorhus/pure
    zplug "sindresorhus/pure", use:pure.zsh, defer:3

# 
#     if ! zplug check --verbose; then
#         printf "Install? [y/N]: "
#         if read -q; then
#             echo; zplug install
#         fi
#     fi
# 
    zplug load  # --verbose
fi

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
alias gpp='git push origin `git_current_branch`'
alias gf='git fetch'
alias gm='git merge'
alias gmom='git merge origin/master'
alias gmum='git merge upstream/master'
alias gst='git status'
alias glog='git log'
alias grm='git rm'
alias grmr='git rm -r'
alias gtag='git tag'
alias gtaga='git tag -a'
alias gdt='git difftool'
alias gdtc='git difftool --cached'
alias gpoft='git push origin --follow-tags'
alias gcm='git checkout master'
alias gco='git checkout'

git-current-branch() {
    git branch | grep "^\* " | sed -e "s/^\* \(.*\)/\1/"
}
# GVM(Go Version Manager)
# https://github.com/moovweb/gvm
[ -s "$HOME/.gvm/scripts/gvm" ] && source "$HOME/.gvm/scripts/gvm"
# hub
# https://hub.github.com/
if builtin command -v hub > /dev/null; then
    alias git=hub
    # eval "$(hub alias -s)"
fi
PACKAGES=(
  yo
  yeoman-generator
  generator-generator
  @angular/cli
  generator-ss-ansible-playbook
  vue-cli
)

LINKS=(
  flask
  jenkins
  elasticsearch-kibana
  consul-servers
)

upgrade-nodebrew() {
  if [ $# -ne 1 ]; then
    echo "the number of argument should be 1" 1>&2
    exit 1
  fi
  NODE_VERSION=$1

  nodebrew install-binary $NODE_VERSION
  nodebrew use $NODE_VERSION

  npm i -g $PACKAGES

  for LINK in "${LINKS[@]}"; do
    ghq get suzuki-shunsuke/generator-ss-$LINK
    cd `ghq root`/github.com/suzuki-shunsuke/generator-ss-$LINK
    if [ -d node_modules ]; then
      rm -R node_modules
    fi
    npm link
  done
}
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
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
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

# load this machine specific configuration
[ -f $HOME/zsh.d/zshrc ] && source $HOME/zsh.d/zshrc
