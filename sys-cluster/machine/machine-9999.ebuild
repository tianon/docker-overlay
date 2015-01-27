# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Machine management for a container-centric world"
HOMEPAGE="https://github.com/docker/machine"
SRC_URI=""

inherit eutils

EGIT_REPO_URI="git://github.com/docker/${PN}.git"
inherit git-2

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
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
