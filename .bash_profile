#!/usr/bin/env bash
# ~/.bash_profile: sourced by the command interpreter for login shells.
[ "$0" = "${BASH_SOURCE[0]}" ] && exit
umask 0022

# MANPATH: setup manual pages search paths including user's private
# directories.
export MANPATH="${HOME}/.local/share/man:/usr/local/share/man:/usr/share/man"

# GOPATH: directory where Golang will store modules.
export GOPATH="${HOME}/.local/gopath"

# PATH: setup binary search paths including user's private directories.
export PATH="${HOME}/.local/bin:${GOPATH}/bin:${PATH}"

# Kopia backup utility.
export KOPIA_ADVANCED_COMMANDS=true
export KOPIA_CHECK_FOR_UPDATES=false
export KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=false

# AWS CLI.
if [ -d "${HOME}/.local/opt/aws-cli/bin" ]; then
	export PATH="${PATH}:${HOME}/.local/opt/aws-cli/bin"
else
	if [ -d "/opt/aws-cli/bin" ]; then
		export PATH="${PATH}:/opt/aws-cli/bin"
	fi
fi

# Google Cloud SDK.
if [ -d "${HOME}/.local/opt/google-cloud-sdk/bin" ]; then
	. "${HOME}/.local/opt/google-cloud-sdk/path.bash.inc"
else
	if [ -d "/opt/google-cloud-sdk/bin" ]; then
		. /opt/google-cloud-sdk/path.bash.inc
	fi
fi

# Special configuration for Google Cloud Shell environment.
if [ -d "/google" ] && [ -e "/.dockerenv" ]; then
	# For Android SDK.
	export ANDROID_HOME="/tmp/android-sdk"

	# Move Gradle temporary directory to /tmp, so it won't store data in
	# user home directory.
	export GRADLE_USER_HOME=/tmp/gradle-temp

	# For graphics over X/VNC.
	export DISPLAY=":1"
else
	if [ -d "${HOME}/.local/opt/android-sdk" ]; then
		export ANDROID_HOME="${HOME}/.local/opt/android-sdk"
		export PATH="${HOME}/.local/opt/android-sdk/platform-tools:${PATH}"
	fi

	if [ -d "${HOME}/.local/opt/android-studio/bin" ]; then
		export PATH="${HOME}/.local/opt/android-studio/bin:${PATH}"
	fi
fi

if ! grep -q '\<docker\>' <<< $(id -Gn); then
	# Termux dev
	export TERMUX_DOCKER_USE_SUDO=true
fi

# Load private bash profile that is not bundled with dotfiles repo.
if [ -f "${HOME}/.bash_profile_private" ]; then
	. "${HOME}"/.bash_profile_private
fi

# Finally, load ~/.bashrc.
[ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
