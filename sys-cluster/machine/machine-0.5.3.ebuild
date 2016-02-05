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
	EGIT_COMMIT="v${MY_PV}"
	SRC_URI="https://github.com/docker/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="Machine management for a container-centric world"
HOMEPAGE="https://github.com/docker/machine"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	cd "src/${EGO_PN}" || die
	epatch_user
}

src_compile() {
	cd "src/${EGO_PN}" || die
	export GOPATH="${WORKDIR}/${P}:${PWD}/Godeps/_workspace"
	make build
}

src_install() {
	cd "src/${EGO_PN}" || die
	dobin "bin/docker-${PN}"
}
