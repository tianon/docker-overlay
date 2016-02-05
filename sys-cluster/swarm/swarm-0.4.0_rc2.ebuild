# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Swarm: a Docker-native clustering system"
HOMEPAGE="https://github.com/docker/swarm"
SRC_URI=""

inherit eutils

if [[ ${PV} == *9999 ]]; then
	SRC_URI=""
	EGIT_REPO_URI="git://github.com/docker/${PN}.git"
	inherit git-2
else
	MY_PV="${PV/_/-}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="https://github.com/docker/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	S="${WORKDIR}/${MY_P}"
	KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND=">=dev-lang/go-1.3"
RDEPEND="dev-vcs/git"

src_prepare() {
	epatch_user
}

src_compile() {
	export GOPATH="${T}/gopath"
	mkdir -pv "$GOPATH/src/github.com/docker" || die
	ln -sv "${S}" "$GOPATH/src/github.com/docker/${PN}" || die
	export GOPATH="$GOPATH:${S}/Godeps/_workspace"
	go build -v -o "docker-$PN" || die
}

src_install() {
	dobin "docker-$PN"
}
