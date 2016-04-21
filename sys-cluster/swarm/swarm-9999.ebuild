# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

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

DESCRIPTION="Swarm: a Docker-native clustering system"
HOMEPAGE="https://github.com/docker/swarm"
LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND=">=dev-lang/go-1.6:="
RDEPEND=""

src_compile() {
	export GOPATH="${WORKDIR}/${P}"
	go build -v -o "docker-$PN" "$EGO_PN" || die
}

src_install() {
	dobin "docker-$PN"
}
