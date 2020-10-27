# uncomment out when profiling
# export ZSH_PROFILING=1
if [ -n "$ZSH_PROFILING" ]; then
  zmodload zsh/zprof && zprof
fi

# load this machine specific configuration
[ -f "$HOME/zsh.d/zshenv" ] && source "$HOME/zsh.d/zshenv"
