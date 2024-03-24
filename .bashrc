#!/usr/bin/env bash
# ~/.bashrc: sourced by bash(1) for non-login shells.
[ "$0" = "${BASH_SOURCE[0]}" ] && exit

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return
umask 0022

# Load script with Bash functions.
if [ -f "${HOME}/.bash_functions" ]; then
	. "${HOME}"/.bash_functions
fi
SYSTEM_TYPE=$(_system_type)

# Special configuration for Google Cloud Shell environment.
# Load before everything else in order to let it be overridden.
if [ "${SYSTEM_TYPE}" = "GCLOUD_SHELL" ]; then
	if [ -f "/google/devshell/bashrc.google" ]; then
		source /google/devshell/bashrc.google
	fi
	rm -f "${HOME:?}/README-cloudshell.txt"
fi

# On serial console we need to be sure whether console size is matching
# the size of a terminal screen.
if [[ "$(tty)" == /dev/ttyS* ]]; then
	PS0='$(eval "$(resize)")'

	if [ "${SHLVL}" = "1" ]; then
		eval "$(resize)"
		printf '\033[!p'
	fi
fi

# Use dynamic command line prompt.
PROMPT_COMMAND="_update_bash_prompt"

# Show 2 directories of CWD context.
PROMPT_DIRTRIM=2

# Secondary prompt configuration.
PS2='> '
PS3='> '
PS4='+ '

# Shell options.
shopt -s autocd
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s globstar
shopt -s histappend
shopt -s histverify

# Configure bash history.
HISTSIZE=8000
HISTFILESIZE=-1
HISTCONTROL="ignoreboth"
HISTTIMEFORMAT="%Y/%m/%d %T : "

# Specify default text editor.
EDITOR=$(command -v nvim)
if [ -z "${EDITOR}" ]; then
	EDITOR=vim
fi
export EDITOR

# Colorful output of GCC.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Colorful output of ls.
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.cfg=00;32:*.conf=00;32:*.diff=00;32:*.doc=00;32:*.ini=00;32:*.log=00;32:*.patch=00;32:*.pdf=00;32:*.ps=00;32:*.tex=00;32:*.txt=00;32:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*.desktop=01;35:'

# Specify default pager.
if [ -n "$(command -v less)" ]; then
	export PAGER="$(command -v less) -R -F"
else
	export PAGER="cat"
fi

# Make less more friendly for non-text input files, see lesspipe(1).
if [ -x "$(command -v lesspipe)" ]; then
	eval "$(SHELL=$(command -v sh) lesspipe)"
fi

# For gpg in terminal.
export GPG_TTY=$(tty)

# Termux can't access smartcard directly. Use OkcAgent app to communicate
# with the device: https://f-droid.org/packages/org.ddosolitary.okcagent/
# Other systems can work through GnuPG agent.
if [ "${SYSTEM_TYPE}" = "ANDROID_TERMUX" ]; then
	if [ -n "$(command -v okc-ssh-agent)" ]; then
		if [ -e "${HOME}/.cache/okc-agent.pid" ]; then
			SSH_AGENT_PID=$(dd if="${HOME}/.cache/okc-agent.pid" bs=1 count=8 2>/dev/null)
			if [ ! -e "/proc/${SSH_AGENT_PID}" ]; then
				SSH_AGENT_PID=""
			fi
		else
			SSH_AGENT_PID=$(pidof okc-ssh-agent 2>/dev/null)
		fi

		if [ -z "${SSH_AGENT_PID}" ]; then
			eval "$(okc-ssh-agent -s -a "${HOME}"/.cache/okc-agent.sock)" >/dev/null 2>&1
			echo "${SSH_AGENT_PID}" > "${HOME}/.cache/okc-agent.pid"
		else
			export SSH_AUTH_SOCK="${HOME}/.cache/okc-agent.sock"
		fi
	fi
else
	if [ -n "$(command -v gpgconf)" ]; then
		export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
		gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null 2>&1
	fi
fi

# Enable direnv support if possible.
# (direnv loads environment variables from .envrc files)
if [ -n "$(command -v direnv)" ]; then
	export DIRENV_LOG_FORMAT=
	eval "$(direnv hook bash)"
fi

# Load script with shell aliases configuration.
if [ -f "${HOME}/.bash_aliases" ]; then
	. "${HOME}"/.bash_aliases
fi

# Enable programmable completion features.
if ! shopt -oq posix; then
	if [ -f "/usr/share/bash-completion/bash_completion" ]; then
		BASH_COMPLETION_FILE="/usr/share/bash-completion/bash_completion"
	elif [ -f "/etc/bash_completion" ]; then
		BASH_COMPLETION_FILE="/etc/bash_completion"
	else
		BASH_COMPLETION_FILE=""
	fi

	if [ -n "${BASH_COMPLETION_FILE}" ]; then
		. "${BASH_COMPLETION_FILE}"
		# The next line enables shell command completion for gcloud.
		if [ -f "${HOME}/.local/opt/google-cloud-sdk/completion.bash.inc" ]; then
			. "${HOME}/.local/opt/google-cloud-sdk/completion.bash.inc"
		else
			if [ -f "/opt/google-cloud-sdk/completion.bash.inc" ]; then
				. "/opt/google-cloud-sdk/completion.bash.inc"
			fi
		fi
	fi

	unset BASH_COMPLETION_FILE
fi

# Show user@host in terminal title by default.
# Use 'term-toggle-hide-userhost' to change.
TERM_TITLE_HIDE_USERHOST=false

# Load private bashrc that is not bundled with dotfiles repo.
if [ -f "${HOME}/.bashrc_private" ]; then
	. "${HOME}"/.bashrc_private
fi

# Prompt user to fix file permissions and run additional steps
# once when the environment is not configured.
_one_time_init
