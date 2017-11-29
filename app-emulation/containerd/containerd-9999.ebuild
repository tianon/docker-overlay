# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN="github.com/containerd/${PN}"

MY_PV="${PV/_/-}"
case "${PV}" in
	*9999)
		inherit golang-vcs
		;;

	*)
		EGIT_COMMIT="v${MY_PV}"
		SRC_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
		KEYWORDS="~amd64"
		inherit golang-vcs-snapshot
		;;
esac

DESCRIPTION="A daemon to control runC"
HOMEPAGE="https://containerd.io"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="btrfs"

DEPEND=""
RDEPEND="
	|| (
		>=app-emulation/runc-1.0.0_rc4[seccomp]
		>=app-emulation/docker-runc-1.0.0_rc4[seccomp]
	)
	sys-libs/libseccomp
"

S=${WORKDIR}/${P}/src/${EGO_PN}

src_prepare() {
	eapply_user
}

src_compile() {
	local options=( $(usex btrfs '' 'no_btrfs') )
	export GOPATH="${WORKDIR}/${P}" # ${PWD}/vendor
	LDFLAGS= emake VERSION="v${MY_PV}" REVISION="$EGIT_COMMIT" BUILDTAGS="${options[*]}"
}

src_install() {
	dobin bin/*
}
