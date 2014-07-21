# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Cli application to manage github pull requests"
HOMEPAGE="https://github.com/docker/gordon"
SRC_URI=""

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

	cd "${S}"
	export GOPATH="$(pwd -P)/.gopath"
	mkdir -p "$GOPATH/src/github.com/docker"
	ln -sf "$(pwd -P)" "$GOPATH/src/github.com/docker/gordon"
	go get -d -v ./...
}

src_compile() {
	export GOPATH="$(pwd -P)/.gopath"
	go install -v github.com/docker/gordon/{pulls,issues}
}

src_install() {
	dobin .gopath/bin/*
}
