{% from 'rc-fusion/macros/local.j2' import local %}
fpath=($(brew --prefix)/share/zsh/site-functions $fpath)

# autoload -Uz compinit
autoload -Uz colors
# compinit -u

alias sudo="sudo -E"
alias ls="gls --color=auto"

bindkey -v

# 
# zmv
autoload -Uz zmv
# 
# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

{{ local([
  "zplug/zshrc",
  "**/zshrc", 
  "!zshrc", 
  "fzf/zshrc",
  "anyframe/zshrc",
  "!npm/zshrc",
  "!dirssh/zshrc",
  "!travis/zshrc",
  "!haskel/zshrc",
]) }}
