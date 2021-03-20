#!/bin/bash
[[ $- != *i* ]] && return

source $HOME/.config/bash/git-status/gitstatus.prompt.sh
PS1="┌─[\[\e[36m\]\u\[\e[m\]@\[\e[31m\]\h\[\e[m\]]-[\A]-[\[\e[35m\]\w\[\e[m\]] \${GITSTATUS_PROMPT} \n└─[> "

export EDITOR=vim
export VISUAL=vim
export NVIMINIT="source /home/$USER/.config/vim/vimrc"

export PATH=$PATH:/home/$USER/.local/bin

HISTSIZE= HISTFILESIZE=

## bc ##
alias bc='bc -l'

## ports ##
alias ports='netstat -tulanp'
alias portss='ss -tulanp'

# get web server headers #
alias header='curl -I'

## colorize commands output for ease of use ##
alias diff='colordiff'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias sgrep='grep --color=auto -rni'
alias ls='ls -F --color=auto -a'
alias lsd='ls --color=auto --group-directories-first -hN'
alias ll='ls -FGlAhp'

# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'
 
# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
 
# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# become root #
alias root='sudo -i'
alias su='sudo -i'

## silver searcher ##
alias agsuper='bash -xc '\''ag --color -g $0 --hidden'\''  2>/dev/null'
alias agsphp='ag $1 --php --hidden 2>/dev/null'
alias agslog='ag $1 --log --hidden 2>/dev/null'

## create parent directories on demand ##
alias mount='mount |column -t'

## ping variations ##
alias fastping='ping -c 100 -s 2'

## resume wget by default##
alias wget='wget -c'

## pass options to free ##
alias meminfo='free -m -l -t'

## ps top 20 ##
alias psmem='ps auxf | sort -nr -k 4 | head -20'
alias pscpu='ps auxf | sort -nr -k 3 | head -20'

## handy short cuts ##
alias h='history'
alias j='jobs -l'
alias c='clear'
alias e='exit'
alias v='vim'

## create parent directories on demand ##
alias mkdir='mkdir -pv'

## octal perms ##
alias ocperms='stat -c "%A %a %n" $1'

## network ##
alias lip='hostname -i'
alias xip='curl -s ifconfig.me -w "\n"'

## termbin paste ##
alias tb='nc termbin.com 9999'

# misc ##
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias dusage="du -h --max-depth=1 | sort -rh"
alias nocomment='grep -Ev '"^(#|$)"''
alias hg='history|grep '
alias conns='sudo lsof -n -P -i +c 15'


## func ##

if [[ $- == *i* ]]
then
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
  bind '"\e[C": forward-char'
  bind '"\e[D": backward-char'
fi

## extraction ##
function extract()
{
    if [ -f "$1" ]
        then
        case $1 in
            *.tar.bz2)  tar xvjf "$1"     ;;
            *.tar.gz)   tar xvzf "$1"     ;;
            *.bz2)      bunzip2 "$1"      ;;
            *.rar)      unrar x "$1"      ;;
            *.gz)       gunzip "$1"       ;;
            *.tar)      tar xvf "$1"      ;;
            *.tbz2)     tar xvjf "$1"     ;;
            *.tgz)      tar xvzf "$1"     ;;
            *.zip)      unzip "$1"        ;;
            *.Z)        uncompress "$1"   ;;
            *.7z)       7z x "$1"         ;;
            *)          echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

## compression ##
function targ() {
    tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"
}

function tarb() {
    tar cvjSf "${1%%/}.tar.bz2" "${1%%/}/"
}

function mkzip() {
    zip -r "${1%%/}.zip" "$1"
}


## dirs manipulation ##
function cdtmp()
{
    temp_dir="$(mktemp -d)"
    [[ -d "$temp_dir" ]] || return 1
    (trap "rm -rf \"$temp_dir\"" EXIT; cd "$temp_dir"; bash -i)
}

function mkcd()
{
    mkdir -p "$@"
    cd "$1"
}

up()
{
    dir=""
    if [[ $1 =~ ^[0-9]+$ ]]; then
        x=0
        while [ $x -lt ${1:-1} ]; do
            dir=${dir}../
            x=$(($x+1))
        done
    else
         dir=..
    fi
    cd "$dir";
}
