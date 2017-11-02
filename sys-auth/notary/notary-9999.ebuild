# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Notary project comprises a server and a client for running and interacting with trusted collections"
HOMEPAGE="https://github.com/theupdateframework/notary"
SRC_URI=""

inherit eutils

if [[ ${PV} == *9999 ]]; then
	SRC_URI=""
	EGIT_REPO_URI="git://github.com/theupdateframework/${PN}.git"
	inherit git-2
else
	MY_PV="${PV/_/-}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="https://github.com/theupdateframework/${PN}/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	S="${WORKDIR}/${MY_P}"
	KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=">=dev-lang/go-1.6"
RDEPEND="dev-vcs/git"

src_prepare() {
	epatch_user
}

src_compile() {
	export GOPATH="${T}/gopath"
	mkdir -pv "$GOPATH/src/github.com/theupdateframework" || die
	ln -sv "${S}" "$GOPATH/src/github.com/theupdateframework/${PN}" || die
	cd "${T}/gopath/src/github.com/theupdateframework/${PN}" || die
	go install -v ./cmd/... || die
}

src_install() {
	dobin "${T}/gopath/bin/"*
}
