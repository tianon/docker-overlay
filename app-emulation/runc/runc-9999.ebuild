# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
EGO_PN="github.com/opencontainers/${PN}"

if [[ ${PV} == *9999 ]]; then
	inherit golang-vcs
else
	MY_PV="${PV/_/-}"
	EGIT_COMMIT="v${MY_PV}"
	RUNC_COMMIT="" # Change this when you update the ebuild
	[ "$RUNC_COMMIT" ] || die "RUNC_COMMIT must be added manually for each bump!"
	SRC_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~ppc64"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="runc container cli tools"
HOMEPAGE="http://runc.io"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="apparmor hardened +seccomp"

RDEPEND="
	apparmor? ( sys-libs/libapparmor )
	seccomp? ( sys-libs/libseccomp )
"

export GOPATH="${WORKDIR}/${P}"
S="${GOPATH}/src/${EGO_PN}"

src_compile() {
	# Taken from app-emulation/docker-1.7.0-r1
	export CGO_CFLAGS="-I${ROOT}/usr/include"
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')
		-L${ROOT}/usr/$(get_libdir)"

	# build up optional flags
	local options=(
		$(usex apparmor 'apparmor')
		$(usex seccomp 'seccomp')
	)

	emake BUILDTAGS="${options[*]}" \
		${RUNC_COMMIT:+"COMMIT=${RUNC_COMMIT}"}
}

src_install() {
	dobin runc
}
