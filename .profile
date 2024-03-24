# This file is read each time a login shell is started.
# All other interactive shells will only read .bashrc.

if [ -e "/data/data/com.termux/files/usr/etc/profile" ]; then
	test -z "${PROFILEREAD}" && . /data/data/com.termux/files/usr/etc/profile || true
else
	test -z "${PROFILEREAD}" && . /etc/profile || true
fi
test -z "${PROFILEREAD}" && export PROFILEREAD=true
