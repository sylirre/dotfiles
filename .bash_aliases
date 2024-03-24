#!/usr/bin/env bash
# ~/.bash_aliases: sourced by ~/.bashrc for interactive shells.
[ "$0" = "${BASH_SOURCE[0]}" ] && exit

# Enable colored output.
alias grep='grep --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias l='ls --color=auto --group-directories-first'
alias ls='ls --color=auto --group-directories-first'
alias l.='ls --color=auto -d --group-directories-first .*'
alias la='ls --color=auto -A --group-directories-first'
alias ll='ls --color=auto -Fhl --group-directories-first'
alias ll.='ls --color=auto -Fhl -d --group-directories-first .*'
alias vdir='vdir --color=auto -h'

# VIM to NVIM.
if [ -n "$(command -v nvim)" ]; then
	alias vim='nvim'
fi

# Docker.
if ! grep -q '\<docker\>' <<< $(id -Gn); then
	alias docker='sudo docker'
fi

# Safety.
alias cp='cp -i'
alias ln='ln -i'
alias mv='mv -i'
alias rm='rm -i --preserve-root'

# Aliases special to Google Cloud Shell environment.
if [ -d "/google" ] && [ -e "/.dockerenv" ]; then
	# Limit amount of parallel queries to name server when running
	# under Google Cloud Shell.
	alias apt='sudo apt -o Acquire::Queue-mode=access'
fi
