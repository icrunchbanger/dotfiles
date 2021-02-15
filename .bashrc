#!/bin/bash
[[ $- != *i* ]] && return

##########################################################
#Please edit "User Configuration" section before using   #
##########################################################

#=========================================================
#Terminal Color Codes
#=========================================================
WHITE='\[\033[1;37m\]'
LIGHTGRAY='\[\033[0;37m\]'
GRAY='\[\033[1;30m\]'
BLACK='\[\033[0;30m\]'
RED='\[\033[0;31m\]'
LIGHTRED='\[\033[1;31m\]'
GREEN='\[\033[0;32m\]'
LIGHTGREEN='\[\033[1;32m\]'
BROWN='\[\033[0;33m\]' #Orange
YELLOW='\[\033[1;33m\]'
BLUE='\[\033[0;34m\]'
LIGHTBLUE='\[\033[1;34m\]'
PURPLE='\[\033[0;35m\]'
PINK='\[\033[1;35m\]' #Light Purple
CYAN='\[\033[0;36m\]'
LIGHTCYAN='\[\033[1;36m\]'
DEFAULT='\[\033[0m\]'

#=========================================================
# User Configuration
#=========================================================
# Colors
cLINES=$GRAY #Lines and Arrow
cBRACKETS=$GRAY # Brackets around each data item
cERROR=$LIGHTRED # Error block when previous command did not return 0
cSUCCESS=$GREEN  # When last command ran successfully and return 0
cTIME=$LIGHTGRAY # The current time
cMPX1=$YELLOW # Color for terminal multiplexer threshold 1
cMPX2=$RED # Color for terminal multiplexer threshold 2
cBGJ1=$YELLOW # Color for background job threshold 1
cBGJ2=$RED # Color for background job threshold 2
cSTJ1=$YELLOW # Color for background job threshold 1
cSTJ2=$RED # Color for  background job threshold 2
cSSH=$PINK # Color for brackets if session is an SSH session
cUSR=$LIGHTBLUE # Color of user
cUHS=$CYAN # Color of the user and hostname separator, probably '@'
cHST=$LIGHTGREEN # Color of hostname
cRWN=$RED # Color of root warning
cPWD=$BLUE # Color of current directory
cCMD=$DEFAULT # Color of the command you type

# Enable block
eNL=0  # Have a newline between previous command output and new prompt
eERR=1 # Previous command return status tracker
eTIME=1 # Enable time display
eMPX=1 # Terminal multiplexer tracker enabled
eSSH=1 # Track if session is SSH
eBGJ=1 # Track background jobs
eSTJ=1 # Track stopped jobs
eHOST=1 # Show user and host
ePWD=1 # Show current directory

# Block settins
MPXT1="0" # Terminal multiplexer threshold 1 value
MPXT2="2" # Terminal multiplexer threshold 2 value
BGJT1="0" # Background job threshold 1 value
BGJT2="2" # Background job threshold 2 value
STJT1="0" # Stopped job threshold 1 value
STJT2="2" # Stopped job threshold 2 value
UHS="@"


function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}


function promptcmd()
{
        PREVRET=$?

        #=========================================================
        #check if user is in ssh session
        #=========================================================
        if [ $eSSH -eq 1 ]; then
                if [[ $SSH_CLIENT ]] || [[ $SSH2_CLIENT ]]; then
                        lSSH_FLAG=1
                else
                        lSSH_FLAG=0
                fi
        fi

        #=========================================================
        # Insert a new line to clear space from previous command
        #=========================================================
        if [ $eNL -eq 1 ]; then
                PS1="\n"
        else
                PS1=""
        fi

        #=========================================================
        # Beginning of first line (arrow wrap around and color setup)
        #=========================================================
        PS1="${PS1}${cLINES}\342\224\214\342\224\200"

        #=========================================================
        # First Dynamic Block - Previous Command Error
        #=========================================================
        if [ $eERR -eq 1 ]; then
                if [ $PREVRET -ne 0 ] ; then
                        PS1="${PS1}${cBRACKETS}[${cERROR}!${cBRACKETS}]${cLINES}\342\224\200"
                else
                        PS1="${PS1}${cBRACKETS}[${cSUCCESS}$(parse_git_branch)${cBRACKETS}]${cLINES}\342\224\200"
                fi
        fi

        #=========================================================
        # First static block - Current time
        #=========================================================
        if [ $eTIME -eq 1 ] ; then
                PS1="${PS1}${cBRACKETS}[${cTIME}\t${cBRACKETS}]${cLINES}\342\224\200"
        fi

        #=========================================================
        # Detached Screen Sessions
        #=========================================================
        if [ $eMPX -eq 1 ] ; then
                hTMUX=0
                hSCREEN=0
                MPXC=0
                hash tmux --help 2>/dev/null || hTMUX=1
                hash screen --version 2>/dev/null || hSCREEN=1
                if [ $hTMUX -eq 0 ] && [ $hSCREEN -eq 0 ] ; then
                        MPXC=$(echo "$(screen -ls | grep -c -i detach) + $(tmux ls 2>/dev/null | grep -c -i -v attach)" | bc)
                elif [ $hTMUX -eq 0 ] && [ $hSCREEN -eq 1 ] ; then
                        MPXC=$(tmux ls 2>/dev/null | grep -c -i -v attach)
                elif [ $hTMUX -eq 1 ] && [ $hSCREEN -eq 0 ] ; then
                        MPXC=$(screen -ls | grep -c -i detach)
                fi
                if [[ $MPXC -gt $MPXT2 ]] ; then
                        PS1="${PS1}${cBRACKETS}[${cMPX2}\342\230\220:${MPXC}${cBRACKETS}]${cLINES}\342\224\200"
                elif [[ $MPXC -gt $MPXT1 ]] ; then
                        PS1="${PS1}${cBRACKETS}[${cMPX1}\342\230\220:${MPXC}${cBRACKETS}]${cLINES}\342\224\200"
                fi
        fi
        #=========================================================
        # Backgrounded running jobs
        #=========================================================
        if [ $eBGJ -eq 1 ] ; then
                BGJC=$(jobs -r | wc -l )
                if [ $BGJC -gt $BGJT2 ] ; then
                        PS1="${PS1}${cBRACKETS}[${cBGJ2}&:${BGJC}${cBRACKETS}]${cLINES}\342\224\200"
                elif [ $BGJC -gt $BGJT1 ] ; then
                        PS1="${PS1}${cBRACKETS}[${cBGJ1}&:${BGJC}${cBRACKETS}]${cLINES}\342\224\200"
                fi
        fi

        #=========================================================
        # Stopped Jobs
        #=========================================================
        if [ $eSTJ -eq 1 ] ; then
                STJC=$(jobs -s | wc -l )
                if [ $STJC -gt $STJT2 ] ; then
                        PS1="${PS1}${cBRACKETS}[${cSTJ2}\342\234\227:${STJC}${cBRACKETS}]${cLINES}\342\224\200"
                elif [ $STJC -gt $STJT1 ] ; then
                        PS1="${PS1}${cBRACKETS}[${cSTJ1}\342\234\227:${STJC}${cBRACKETS}]${cLINES}\342\224\200"
                fi
        fi

        #=========================================================
        # Second Static block - User@host
        #=========================================================
        # set color for brackets if user is in ssh session
        if [ $eSSH -eq 1 ] && [ $lSSH_FLAG -eq 1 ] ; then
                sesClr="$cSSH"
        else
                sesClr="$cBRACKETS"
        fi
        # don't display user if root
        if [ $EUID -eq 0 ] ; then
                PS1="${PS1}${sesClr}[${cRWN}!"
        else
                PS1="${PS1}${sesClr}[${cUSR}\u"
        fi
        # Host Section
        if [ $eHOST -eq 1 ] || [ $lSSH_FLAG -eq 1 ] ; then   # Host is optional only without SSH
                PS1="${PS1}${cUHS}${UHS}${cHST}\h${sesClr}]${cLINES}\342\224\200"
        else
                PS1="${PS1}${sesClr}]${cLINES}\342\224\200"
        fi

        #=========================================================
        # Third Static Block - Current Directory
        #=========================================================
        if [ $ePWD -eq 1 ]; then
                PS1="${PS1}[${cPWD}\w${cBRACKETS}]"
        fi

        #=========================================================
        # Second Line
        #=========================================================
        PS1="${PS1}\n${cLINES}\342\224\224\342\224\200\342\224\200> ${cCMD}"
}


function load_prompt () {
    # Get PIDs
    local parent_process=$(tr -d '\0' < /proc/$PPID/cmdline | cut -d \. -f 1)
    local my_process=$(tr -d '\0' < /proc/$$/cmdline | cut -d \. -f 1)

    if  [[ $parent_process == script* ]]; then
        PROMPT_COMMAND=""
        PS1="\t - \# - \u@\H { \w }\$ "
    elif [[ $parent_process == emacs* || $parent_process == xemacs* ]]; then
        PROMPT_COMMAND=""
        PS1="\u@\h { \w }\$ "
    else
        export DAY=$(date +%A)
        PROMPT_COMMAND=promptcmd
     fi
    export PS1 PROMPT_COMMAND
}

load_prompt

export EDITOR=nvim
export VISUAL=nvim
alias  vim='nvim'
#export NEOVIMINIT="source /home/$USER/.config/nvim/vimrc"

export PATH=$PATH:/home/$USER/.local/bin

HISTSIZE= HISTFILESIZE=

## bc ##
alias bc='bc -l'

## ports ##
alias ports='netstat -tulanp'
alias portss='ss -tulanp'

## shortcut  for iptables and pass it via sudo#
alias ipt='sudo /sbin/iptables'
 
# display all rules #
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'
alias firewall=iptlist

# get web server headers #
alias header='curl -I'
 
# find out if remote server supports gzip / mod_deflate or not #
alias headerc='curl -I --compress'

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
alias xip='curl ifconfig.me'

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

#vim()
#{
#   if [ -x "$(command -v nvim)" ]; then
#	exec nvim "$1";
#   else
#        exec vim "$1"
#   fi
#}
