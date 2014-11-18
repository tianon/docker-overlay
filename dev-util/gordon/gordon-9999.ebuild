# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Cli application to manage github pull requests"
HOMEPAGE="https://github.com/docker/gordon"
SRC_URI=""

export GOPATH="${T}/gopath"
S="${GOPATH}/src/github.com/docker/gordon"

EGIT_REPO_URI="git://github.com/docker/gordon"
inherit git-2

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=">=dev-lang/go-1.2"
RDEPEND="dev-vcs/git"

src_unpack() {
	git-2_src_unpack

	cd "${S}" || die
	go get -d -v ./... || die
}

src_prepare() {
	epatch_user
}

src_compile() {
	go install -v ./... || die
}

src_install() {
	dobin "$GOPATH"/bin/*
}
