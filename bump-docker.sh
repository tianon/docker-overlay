#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

git pull -q || true

newVersion="$1"
if [ ! "$newVersion" ]; then
	echo >&2 "usage: $0 version"
	echo >&2 "   ie: $0 0.4.0"
	exit 1
fi

# if a glob comes back empty handed, get rid of it
shopt -s nullglob

if [ "$newVersion" = 'latest' ]; then
	newVersion="$(wget -qO - 'https://get.docker.io/latest')"
fi

ebuildVersion="${newVersion//-/_}"
ebuildVersion="${ebuildVersion//_ce/}"

ebuilds=( app-emulation/docker/docker-${ebuildVersion}*.ebuild )
binEbuilds=( app-emulation/docker-bin/docker-bin-${ebuildVersion}*.ebuild )
if [ ${#ebuilds[@]} -gt 0 ] && [ ${#binEbuilds[@]} -gt 0 ]; then
	exit 0
fi

set -x

#if [ ! -e app-emulation/docker-bin/docker-bin-$ebuildVersion.ebuild ]; then
#	ebuilds=( app-emulation/docker-bin/docker-bin-*.ebuild )
#	cp \
#		"${ebuilds[-1]}" \
#		app-emulation/docker-bin/docker-bin-$ebuildVersion.ebuild
#fi
#ebuild app-emulation/docker-bin/docker-bin-$ebuildVersion.ebuild digest
#git add app-emulation/docker-bin/docker-bin-$ebuildVersion.ebuild

if [ ! -e app-emulation/docker/docker-$ebuildVersion.ebuild ]; then
	cp \
		app-emulation/docker/docker-9999.ebuild \
		app-emulation/docker/docker-$ebuildVersion.ebuild
fi
commit="$({
	git ls-remote --tags https://github.com/docker/docker-ce.git "refs/tags/v$newVersion^{}"
	git ls-remote --tags https://github.com/docker/docker.git "refs/tags/v$newVersion^{}"
} | cut -b -7)"
if [ -z "$commit" ]; then
	commit="$({
		git ls-remote --tags https://github.com/docker/docker-ce.git "refs/tags/v$newVersion"
		git ls-remote --tags https://github.com/docker/docker.git "refs/tags/v$newVersion"
	} | cut -b -7)"
fi
sed -i 's/DOCKER_GITCOMMIT=".*"/DOCKER_GITCOMMIT="'$commit'"/' app-emulation/docker/docker-$ebuildVersion.ebuild

#eval "$(emerge --info | grep ^DISTDIR=)"
#: ${DISTDIR:=/usr/portage/distfiles}
#if [ ! -s "$DISTDIR/docker-$ebuildVersion.tar.gz" ]; then
#	wget -O "$DISTDIR/docker-$ebuildVersion.tar.gz" "https://github.com/docker/docker/archive/v${newVersion}.tar.gz"
#fi

ebuild app-emulation/docker/docker-$ebuildVersion.ebuild digest
#git add app-emulation/docker/docker-$ebuildVersion.ebuild

#git add app-emulation/docker-bin/Manifest
#git add app-emulation/docker/Manifest

#repoman fix
#repoman full
