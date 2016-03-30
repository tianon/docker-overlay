# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

EGO_PN="github.com/docker/${PN}"

if [[ ${PV} == *9999 ]]; then
	inherit golang-vcs
else
	MY_PV="${PV/_/-}"
	EGIT_COMMIT="${MY_PV}"
	SRC_URI="https://github.com/docker/${PN}/archive/v${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="A daemon to control runC"
HOMEPAGE="https://containerd.tools"
LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="app-emulation/runc"

src_prepare() {
	cd "src/${EGO_PN}" || die
	epatch_user
}

src_compile() {
	cd "src/${EGO_PN}" || die
	export GOPATH="${WORKDIR}/${P}" # ${PWD}/vendor
	[ -z "$EGIT_COMMIT" ] || export GIT_COMMIT="$EGIT_COMMIT"
	LDFLAGS= make
}

src_install() {
	cd "src/${EGO_PN}" || die
	dobin bin/containerd* bin/ctr
}
