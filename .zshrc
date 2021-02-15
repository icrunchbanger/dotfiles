export PS1="[%D{%K:%M}|%D{%d-%m}] %d > " 
autoload -Uz compinit
compinit

export EDITOR=vim

SAVEHIST=1000000
HISTFILE=~/.zsh_history

export TERMINFO=/usr/share/terminfo
export TERM=xterm-basic

bindkey '^R' history-incremental-search-backward

## colorize commands output for ease of use ##
alias diff='colordiff'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ls='ls -a --color=auto'
alias lsd='ls -hN --color=auto --group-directories-first'

## create parent directories on demand ##
alias mount='mount |column -t'

## ping variations ##
alias ping='ping -c 5'
alias fastping='ping -c 100 -s.2'

## resume wget by default##
alias wget='wget -c'

## pass options to free ##
alias meminfo='free -m -l -t'
 
## ps top 10 ##
alias psmem='ps auxf | sort -nr -k 4 | head -20'
alias pscpu='ps auxf | sort -nr -k 3 | head -20'

## handy short cuts ##
alias h='history'
alias j='jobs -l'
alias c='clear'

## create parent directories on demand ##
alias mkdir='mkdir -pv'