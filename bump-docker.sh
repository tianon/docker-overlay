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

ebuilds=( app-emulation/docker/docker-${newVersion}*.ebuild )
binEbuilds=( app-emulation/docker-bin/docker-bin-${newVersion}*.ebuild )
if [ ${#ebuilds[@]} -gt 0 ] && [ ${#binEbuilds[@]} -gt 0 ]; then
	exit 0
fi

set -x

if [ ! -e app-emulation/docker-bin/docker-bin-$newVersion.ebuild ]; then
	ebuilds=( app-emulation/docker-bin/docker-bin-*.ebuild )
	cp \
		"${ebuilds[-1]}" \
		app-emulation/docker-bin/docker-bin-$newVersion.ebuild
fi
ebuild app-emulation/docker-bin/docker-bin-$newVersion.ebuild digest
git add app-emulation/docker-bin/docker-bin-$newVersion.ebuild

if [ ! -e app-emulation/docker/docker-$newVersion.ebuild ]; then
	cp \
		app-emulation/docker/docker-9999.ebuild \
		app-emulation/docker/docker-$newVersion.ebuild
fi
ebuild app-emulation/docker/docker-$newVersion.ebuild digest
git add app-emulation/docker/docker-$newVersion.ebuild

git add app-emulation/docker{,-bin}/Manifest

repoman fix
repoman full
