####
# .zshrc file
####

# Path
export LANG=ja_JP.UTF-8
# Use colors
autoload -Uz colors
colors
# Command History
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
# PROMPT
# Single line
# PROMPT="%~ %# "
# Multiple lines
PROMPT="%{${fg[magenta]}%}[%n@%m]%{${reset_color}%} %~
[%*] %# "
# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

########################################

# vcs_info
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

function _update_vcs_info_msg() {
    LANG=en_US.UTF-8 vcs_info
    RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg


########################################
# opstions
setopt print_eight_bit
setopt no_beep
setopt no_flow_control
setopt ignore_eof
setopt interactive_comments
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt share_history
setopt hist_reduce_blanks
setopt extended_glob

########################################
# alias

alias la='ls -a'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias sudo='sudo '
alias -g L='| less'
alias -g G='| grep'
alias petcopy='pet search | pbcopy'

########################################
# os settings
case ${OSTYPE} in
    darwin*)
        # for mac 
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        #for linux
        alias ls='ls -F --color=auto'
        ;;
esac

# for peco
# usage: ctrl + R
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N peco-history-selection
bindkey '^R' peco-history-selection

# ec2-ssh
function ec2-ssh() {
  local user="ec2-user"
  local host=$(aws ec2 describe-instances --region ap-northeast-1 --output json --filters "Name=instance-state-code,Values=16" | jq -r '.Reservations[].Instances[] | [.Tags[] | select(.Key == "Name").Value][] + "\t" +  .InstanceType + "\t" + .PublicIpAddress + "\t" + .Platform' | awk '{if ($4 != "windows") printf "%-45s %-15s %-10s\n",$1,$2,$3}' | sort | /usr/local/bin/peco | awk '{print $3}')
  ssh -A "$user@$host"
}

# awscli completer for zsh
source /usr/local/bin/aws_zsh_completer.sh

# for hyper
# Override auto-title when static titles are desired ($ title My new title)
title() { export TITLE_OVERRIDDEN=1; echo -en "\e]0;$*\a"}
# Turn off static titles ($ autotitle)
autotitle() { export TITLE_OVERRIDDEN=0 }; autotitle
# Condition checking if title is overridden
overridden() { [[ $TITLE_OVERRIDDEN == 1 ]]; }
# Echo asterisk if git state is dirty
gitDirty() { [[ $(git status 2> /dev/null | grep -o '\w\+' | tail -n1) != ("clean"|"") ]] && echo "*" }

# Show cwd when shell prompts for input.
precmd() {
   if overridden; then return; fi
   cwd=${$(pwd)##*/} # Extract current working dir only
   print -Pn "\e]0;$cwd$(gitDirty)\a" # Replace with $pwd to show full path
}

# Prepend command (w/o arguments) to cwd while waiting for command to complete.
preexec() {
   if overridden; then return; fi
   printf "\033]0;%s\a" "${1%% *} | $cwd$(gitDirty)" # Omit construct from $1 to show args
}