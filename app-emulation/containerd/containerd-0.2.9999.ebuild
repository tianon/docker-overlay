# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN="github.com/containerd/${PN}"

case "${PV}" in
	0.2.9999)
		EGIT_REPO_URI="https://${EGO_PN}.git"
		EGIT_CHECKOUT_DIR="${WORKDIR}/${P}/src/${EGO_PN}"
		EGIT_BRANCH="v0.2.x"
		inherit git-r3
		;;

	*9999)
		inherit golang-vcs
		;;

	*)
		MY_PV="${PV/_/-}"
		EGIT_COMMIT="v${MY_PV}"
		SRC_URI="https://${EGO_PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
		KEYWORDS="~amd64"
		inherit golang-vcs-snapshot
		;;
esac

DESCRIPTION="A daemon to control runC"
HOMEPAGE="https://containerd.tools"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+seccomp"

DEPEND=""
RDEPEND="
	|| (
		>=app-emulation/runc-1.0.0_rc2[seccomp?]
		>=app-emulation/docker-runc-1.0.0_rc2[seccomp?]
	)
	seccomp? ( sys-libs/libseccomp )
"

S=${WORKDIR}/${P}/src/${EGO_PN}

src_prepare() {
	eapply_user
}

src_compile() {
	local options=( $(usex seccomp "seccomp") )
	export GOPATH="${WORKDIR}/${P}" # ${PWD}/vendor
	LDFLAGS= emake GIT_COMMIT="$EGIT_COMMIT" BUILDTAGS="${options[@]}"
}

src_install() {
	dobin bin/containerd* bin/ctr
}
