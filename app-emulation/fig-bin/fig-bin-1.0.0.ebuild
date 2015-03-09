# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Fast, isolated development environments using Docker"
HOMEPAGE="http://www.fig.sh"
MY_PN="${PN%-bin}"
MY_PV="${PV/_/-}"
SRC_URI="
	amd64? ( https://github.com/docker/fig/releases/download/${MY_PV}/${MY_PN}-Linux-x86_64 -> ${P}-Linux-x86_64 )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

RESTRICT="installsources strip"

S="${DISTDIR}"

src_install() {
	newbin ${P}-Linux-x86_64 ${MY_PN}
}
