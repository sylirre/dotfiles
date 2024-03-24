#!/usr/bin/env bash
# ~/.bash_functions: sourced by ~/.bashrc for interactive shells.
[ "$0" = "${BASH_SOURCE[0]}" ] && exit

## Determine the type of system where the shell was launched.
## This is later used for enabling system-specific features.
_system_type() {
	if [ -d "/google" ] && [ -e "/.dockerenv" ]; then
		echo "GCLOUD_SHELL"
	elif [ -e "/data/data/com.termux/files/usr" ] && [ -e "/system" ]; then
		echo "ANDROID_TERMUX"
	elif [ "$(uname -m)" = "x86_64" ] && [ "$(hostname)" = "morningstar" ]; then
		echo "LAPTOP"
	elif [ "$(uname -m)" = "x86_64" ] && [ "$(hostname)" = "ubuntu" ]; then
		echo "UBUNTU_PORTABLE"
	elif grep -q QEMU /proc/cpuinfo && [ -e "/lib/ld-musl-x86_64.so.1" ]; then
		echo "ANDROID_ALPINELINUX_QEMU"
	else
		echo "UNKNOWN"
	fi
}

## Prompt user to perform one time initialization if necessary.
_one_time_init() {
	[ -z "${HOME}" ] && return 1
	[[ $- != *i* ]] && return 1

	local skip=true
	local system_type
	system_type=$(_system_type)

	# Configure on known systems if not set up previously.
	if [ "${system_type}" != "UNKNOWN" ] && [ ! -e "${HOME}/.dotfiles_configured" ]; then
		local choice
		read -re -p "[dotfiles] Do you want to perform one-time initialization of environment? (y/n): " choice
		if [[ "${choice}" =~ ^[yY]$ ]]; then
			skip=false
		fi
	fi

	if ! ${skip}; then
		case "${system_type}" in
			ANDROID_TERMUX)
				local termux_mirror="https://mirror.mwt.me/termux/main"
				cat <<- EOF > /data/data/com.termux/files/usr/etc/apt/sources.list
				deb ${termux_mirror} stable main
				EOF

				apt update

				yes | apt full-upgrade -q

				# Needed again as upgrade may overwrite repository configuration.
				cat <<- EOF > /data/data/com.termux/files/usr/etc/apt/sources.list
				deb ${termux_mirror} stable main
				EOF

				apt update

				yes | apt install -q \
					7zip age b3sum bash-completion binutils-is-llvm brotli \
					bsdtar build-essential bzip2 codecrypt cpio croc curl \
					diffutils direnv dog dos2unix ed exiftool fdupes ffmpeg \
					file findutils git gnupg golang graphicsmagick grep gzip \
					hexedit ipfs jq lhasa lrzip lsof lz4 lzip lzop \
					mathomatic mktorrent nano ncdu neovim netcat-openbsd \
					net-tools nmap nmap-ncat okc-agents openssh openssl-tool \
					par2 pdfgrep procps proxychains-ng psmisc pwgen python \
					rclone rhash ripgrep rsync seccure secure-delete sed \
					shellcheck socat ssss strace tar termux-api timg tmux \
					tor tree unzip upx wget which xorriso xz-utils zip \
					zopfli zpaq zstd

				rm -f /data/data/com.termux/files/home/.termux_authinfo
			;;
			ANDROID_ALPINELINUX_QEMU)
				if [ -z "$(command -v sudo)" ]; then
					echo "[dotfiles] No sudo installed, delaying configuration."
					return
				fi

				cat <<- EOF | sudo tee /etc/apk/repositories
				#/media/sr0/apks
				http://dl-cdn.alpinelinux.org/alpine/edge/main
				http://dl-cdn.alpinelinux.org/alpine/edge/community
				http://dl-cdn.alpinelinux.org/alpine/edge/testing
				EOF

				sudo apk update
				sudo apk upgrade
				sudo apk add \
					7zip alpine-sdk aria2 autoconf automake autossh bison \
					brotli bzip2 cmake coreutils cpio croc cryptsetup curl \
					dialog diffutils direnv docker docker-cli-buildx dog \
					dos2unix ed encfs exiftool fdupes ffmpeg file \
					findutils flex flex-dev gallery-dl gawk gdb \
					gettext-dev git gnupg go gocryptfs gperf \
					graphicsmagick grep grub gzip htop intltool jq kopia \
					less libarchive-tools libtool lrzip lsof ltrace lynx \
					lz4 lzip lzo mandoc man-pages man-pages-posix nano \
					nano-syntax neovim netcat-openbsd nmap nmap-ncat \
					nmap-nping nmap-scripts nsnake openssh openvpn \
					par2cmdline patch pdfgrep procps-ng psmisc pwgen \
					py3-pip rclone ripgrep rsync samurai sed shadow \
					shellcheck socat sshfs ssss steghide strace tar task \
					texinfo timewarrior tmux tzdata unzip upx util-linux \
					vim vim-tutor wget which xorriso xxd xz yq yt-dlp zip \
					zlib-dev zopfli zstd

				# Documentation (manpages) has to be installed manually.
				# This compiled list includes docs for above packages as well
				# as for dependencies.
				sudo apk add \
					7zip-doc abuild-doc apk-tools-doc aria2-doc attr-doc \
					autoconf-doc automake-doc autossh-doc bash-doc \
					binutils-doc bison-doc brotli-doc busybox-doc \
					bzip2-doc ca-certificates-doc c-ares-doc cmake-doc \
					containerd-doc coreutils-doc cpio-doc cryptsetup-doc \
					curl-doc dialog-doc diffutils-doc direnv-doc \
					docker-doc dog-doc dos2unix-doc ed-doc encfs-doc \
					fakeroot-doc fdupes-doc ffmpeg-doc file-doc \
					findutils-doc flex-doc fontconfig-doc freetype-doc \
					fribidi-doc fuse3-doc fuse-doc gallery-dl-doc gawk-doc \
					gcc-doc gdb-doc gdbm-doc gettext-doc giflib-doc \
					git-doc glib-doc gmp-doc gnupg-doc gnutls-doc \
					gocryptfs-doc go-doc gperf-doc graphicsmagick-doc \
					grep-doc grub-doc gzip-doc harfbuzz-doc htop-doc \
					intltool-doc iptables-doc jq-doc json-c-doc kmod-doc \
					lcms2-doc less-doc libarchive-doc libassuan-doc \
					libasyncns-doc libbsd-doc libburn-doc libcap-ng-doc \
					libeconf-doc libedit-doc libffi-doc libgcrypt-doc \
					libgpg-error-doc libheif-doc libidn2-doc \
					libisoburn-doc libjpeg-turbo-doc libjxl-doc \
					libksba-doc libmcrypt-doc libmd-doc libmhash-doc \
					libogg-doc libpcap-doc libpciaccess-doc libpng-doc \
					libpsl-doc libseccomp-doc libsndfile-doc libssh2-doc \
					libtasn1-doc libtermkey-doc libtheora-doc libtool-doc \
					libunistring-doc libvorbis-doc libwebp-doc libx11-doc \
					libxau-doc libxcb-doc libxdmcp-doc libxext-doc \
					libxfixes-doc libxml2-doc linux-pam-doc lrzip-doc \
					lsof-doc ltrace-doc luajit-doc lynx-doc lz4-doc \
					lzip-doc lzo-doc m4-doc make-doc mandoc-doc \
					mkinitfs-doc mpc1-doc mpdecimal-doc mpfr4-doc nano-doc \
					neovim-doc netcat-openbsd-doc nmap-doc nsnake-doc \
					numactl-doc openssh-doc openssl-doc openvpn-doc \
					opus-doc p11-kit-doc par2cmdline-doc patch-doc \
					pcre2-doc pcre-doc pdfgrep-doc perl-clone-doc perl-doc \
					perl-encode-locale-doc perl-error-doc \
					perl-file-listing-doc perl-html-parser-doc \
					perl-html-tagset-doc perl-http-cookies-doc \
					perl-http-date-doc perl-http-message-doc \
					perl-http-negotiate-doc perl-image-exiftool-doc \
					perl-io-html-doc perl-libwww-doc \
					perl-lwp-mediatypes-doc perl-net-http-doc \
					perl-try-tiny-doc perl-uri-doc perl-www-robotrules-doc \
					perl-xml-parser-doc pinentry-doc pkgconf-doc \
					poppler-doc popt-doc procps-ng-doc psmisc-doc \
					pwgen-doc py3-pip-doc python3-doc rclone-doc \
					readline-doc ripgrep-doc rsync-doc runc-doc \
					samurai-doc sdl2-doc sed-doc shadow-doc shellcheck-doc \
					skalibs-doc socat-doc soxr-doc speexdsp-doc sshfs-doc \
					ssss-doc steghide-doc strace-doc tar-doc task-doc \
					texinfo-doc tiff-doc timewarrior-doc tmux-doc \
					tzdata-doc unibilium-doc unzip-doc upx-doc \
					util-linux-doc vim-doc wget-doc which-doc xz-doc \
					yt-dlp-doc zimg-doc zip-doc zlib-doc zopfli-doc \
					zstd-doc

				cat <<- EOF | sudo tee /etc/sudoers.d/$(whoami)_extra
				Cmnd_Alias ADMIN_NOPASSWD = \
					/sbin/service docker start, /sbin/service docker stop, /sbin/service docker restart, \
					/sbin/service ntpd start, /sbin/service ntpd stop, /sbin/service ntpd restart, \
					/sbin/service sshd start, /sbin/service sshd stop, /sbin/service sshd restart
				$(whoami) ALL=(ALL:ALL) NOPASSWD: ADMIN_NOPASSWD
				EOF

				sudo usermod -aG abuild,docker,kvm,users $(whoami)
				sudo rc-update add sshd default
			;;
			LAPTOP|UBUNTU_PORTABLE)
				if [ -z "$(command -v sudo)" ]; then
					echo "[dotfiles] No sudo installed, delaying configuration."
					return
				fi

				sudo apt update
				sudo apt full-upgrade -yq
				sudo apt install -yq \
					7zip ace adb age ansible aria2 arj attr autoconf \
					automake awscli bc bison brotli btop btrfs-progs \
					build-essential bzip2 cargo cmake codecrypt cpio \
					curl dc dconf-editor dcraw direnv docker-buildx \
					docker-compose docker.io ecryptfs-utils encfs \
					exfatprogs exiftool f2fs-tools fastboot fdupes \
					ffmpeg file-roller flex fscrypt gettext gifsicle \
					gimp git git-crypt git-lfs gnupg gocryptfs golang \
					gperf graphicsmagick gzip hexedit inkscape intltool \
					irssi itstool jq keepassxc libarchive-tools \
					libcharon-extra-plugins libjpeg-turbo-progs \
					libreoffice libtool lm-sensors lrzip ltrace lynx lz4 \
					lzip lziprecover lzop manpages manpages-dev mktorrent \
					mtools ncat ncdu neovim netcat-openbsd \
					network-manager-strongswan ngrep ninja-build nmap \
					ntfs-3g obfs4proxy openssh-server pandoc par2 patchelf \
					pdfgrep postgresql-client proxychains-ng pwgen python3 \
					python3-pip python-is-python3 qbittorrent qemu-system \
					qemu-utils qrencode rar rclone remmina rhash ripgrep \
					rsync rzip scdaemon secure-delete shellcheck \
					smartmontools socat sqlite3 squashfs-tools sshfs \
					steghide strace tar tcpdump testdisk tmux tor torsocks \
					totem ubuntu-restricted-extras unace unrar unzip upx \
					virt-manager vlc wireguard-tools wireshark xorriso \
					xz-utils yubikey-manager yubikey-personalization zip \
					zopfli zpaq zstd

				# Optional packages that may not be present in the current
				# distribution version where dotfiles are placed.
				sudo apt install -yq yq || true

				# Development libraries.
				sudo apt install -yq \
					gnutls-dev libarchive-dev libboost-all-dev libbz2-dev \
					libcurl4-nss-dev libheif-dev libjansson-dev \
					libjbig2dec-dev libjpeg-dev liblzma-dev libmagic-dev \
					libpng-dev libssl-dev libtiff-dev libwebp-dev \
					libykpers-1-dev libyubikey-dev libzstd-dev ntfs-3g-dev \
					python3-dev qt5-qmake qtbase5-dev qtchooser zlib1g-dev

				# Snap packages.
				for snap in google-cloud-sdk helm kubectl radare2 terraform; do
					sudo snap install --classic "${snap}"
				done
				for snap in dog gallery-dl telegram-desktop yt-dlp; do
					sudo snap install "${snap}"
				done
				unset snap

				if [[ $(findmnt -bno size /) -ge $((25 * 1024 * 1048576)) ]]; then
					sudo snap install xonotic
				fi

				# Sideloaded & custom packages.
				for deb_link in \
					"https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
					"https://github.com/derailed/k9s/releases/download/v0.31.8/k9s_linux_amd64.deb" \
					"https://github.com/kopia/kopia/releases/download/v0.15.0/kopia_0.15.0_linux_amd64.deb"; \
				do
					rm -f /tmp/debfile.tmp
					curl --fail --location --output /tmp/debfile.tmp "${deb_link}"
					mv -f /tmp/debfile.tmp /tmp/debfile.deb
					sudo dpkg -i /tmp/debfile.deb
					rm -f /tmp/debfile.deb
				done

				mkdir /tmp/croc_install_tmpdir
				curl --fail --location --output /tmp/croc_install_tmpdir/file.tar.gz \
					https://github.com/schollz/croc/releases/download/v9.6.14/croc_v9.6.14_Linux-64bit.tar.gz
				tar -C /tmp/croc_install_tmpdir -zxvf /tmp/croc_install_tmpdir/file.tar.gz
				mkdir -p ${HOME}/.local/bin/
				mv -f /tmp/croc_install_tmpdir/croc ${HOME}/.local/bin/
				rm -rf /tmp/croc_install_tmpdir

				sudo usermod -aG docker,kvm,users $(whoami)

				# Disable NTFS3 module as messes up filesystem somehow, so
				# the newly created files are not accessible on a system
				# with a proprietary Tuxera's NTFS driver.
				# Stick to NTFS-3G for now.
				echo "blacklist ntfs3" | sudo tee /etc/modprobe.d/disable-ntfs3.conf

				# Special case for portable Ubuntu installation on USB drive.
				if [ "${system_type}" = "UBUNTU_PORTABLE" ]; then
					sudo apt install -yq --install-recommends \
						forensics-all forensics-extra borgbackup bup \
						clonezilla dar dump duplicity nouveau-firmware \
						partimage rdiff-backup restic snapraid syslinux \
						syslinux-efi
					sudo usermod -aG wireshark $(whoami)
					if [[ $(findmnt -bno size /) -ge $((25 * 1024 * 1048576)) ]]; then
						sudo apt install -yq \
							virtualbox virtualbox-guest-additions-iso
						sudo usermod -aG vboxusers $(whoami)
					fi
				fi
			;;
			*);;
		esac

		touch "${HOME}"/.bash_profile_private
		touch "${HOME}"/.bashrc_private

		local private_file
		for private_file in "${HOME}/.config" "${HOME}/.config/croc" \
			"${HOME}/.config/croc/receive.json" \
			"${HOME}/.config/croc/send.json" "${HOME}/.config/rclone" \
			"${HOME}/.config/rclone/rclone.conf" "${HOME}/.gnupg" \
			"${HOME}/.gnupg/gpg-agent.conf" "${HOME}/.gnupg/gpg.conf" \
			"${HOME}/.local" "${HOME}/.ssh" "${HOME}/.ssh/authorized_keys" \
			"${HOME}/.ssh/config" "${HOME}/.ssh/known_hosts" \
			"${HOME}/.taskwarrior" "${HOME}/.termux" "${HOME}/.timewarrior" \
			"${HOME}/.bash_aliases" "${HOME}/.bash_functions" \
			"${HOME}/.bash_logout" "${HOME}/.bash_profile" \
			"${HOME}/.bash_profile_private" "${HOME}/.bashrc" \
			"${HOME}/.bashrc_private" "${HOME}/.customize_environment" \
			"${HOME}/.envrc" "${HOME}/.gitconfig" "${HOME}/.profile" \
			"${HOME}/.taskrc" "${HOME}/.tmate.conf";
		do
			if [ -e "${private_file}" ]; then
				chmod g-rwx,o-rwx "${private_file}"
			fi
		done
	fi

	if [ ! -d "${HOME}/.cache" ]; then
		mkdir -p "${HOME}/.cache"
		chmod 700 "${HOME}/.cache"
	fi
	date +%s > "${HOME}"/.dotfiles_configured
	unset -f _one_time_init
}

## Used by PROMPT_COMMAND.
_update_bash_prompt() {
	# Update shell history immediately, not just on logout.
	#history -a
	#history -r

	# Add user@host prefix when connected over SSH.
	local user_host
	if [ -n "${SSH_CLIENT}" ] && [ -z "${PROMPT_DISABLE_USERHOST}" ]; then
		user_host="\\[\\e[1;35m\\]\\u\\[\\e[1;36m\\]@\\[\\e[1;35m\\]\\h\\[\\e[0m\\] "
	else
		user_host=""
	fi

	# Add Git branch information.
	local git_branch=""
	if [ -n "$(command -v git)" ]; then
		git_branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\\[\\e[0;33m\\](\1)\\[\\e[0m\\] /')
	fi

	# Add Python virtual environment information.
	local py_virtualenv=""
	if [ -n "${VIRTUAL_ENV}" ]; then
		py_virtualenv="\\[\\e[0;90m\\]($(basename "${VIRTUAL_ENV}"))\\[\\e[0m\\] "
	fi

	# Add GCP project information.
	# Applicable only to Google Cloud Shell environment.
	local gcp_project=""
	if [ -n "${DEVSHELL_PROJECT_ID}" ]; then
		gcp_project=$(printf "\\[\\e[0;34m\\][%s]\\[\\e[0m\\] " "${DEVSHELL_PROJECT_ID}")
	fi

	# Finally build the PS1 prompt.
	PS1="${py_virtualenv}${user_host}\\[\\e[0;32m\\]\\w\\[\\e[0m\\] ${gcp_project}${git_branch}\\[\\e[0;97m\\]\\$\\[\\e[0m\\] "

	# Set title for Xterm-compatible terminals.
	if [[ "${TERM}" =~ ^(xterm|rxvt) ]]; then
		if [ "${TERM_TITLE_HIDE_USERHOST-false}" = "true" ]; then
			PS1="\\[\\e]0;Terminal\\a\\]${PS1}"
		else
			if [ -n "${DEVSHELL_PROJECT_ID}" ]; then
				if [ -e "/google/devshell/customize_environment_done" ]; then
					PS1="\\[\\e]0;[Cloud Shell: ${DEVSHELL_PROJECT_ID}]: \\w\\a\\]${PS1}"
				else
					PS1="\\[\\e]0;[Cloud Shell: setup in-progress]: \\w\\a\\]${PS1}"
				fi
			else
				PS1="\\[\\e]0;\\u@\\h: \\w\\a\\]${PS1}"
			fi
		fi
	fi
}

# Toggle user@host hiding,
term-toggle-hide-userhost() {
	if [ "${TERM_TITLE_HIDE_USERHOST}" = "true" ]; then
		TERM_TITLE_HIDE_USERHOST=false
	else
		TERM_TITLE_HIDE_USERHOST=true
	fi
	_update_bash_prompt
	reset
}
