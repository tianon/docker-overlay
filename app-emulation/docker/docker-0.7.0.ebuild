# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Docker complements LXC with a high-level API which operates at the process level."
HOMEPAGE="http://www.docker.io/"
SRC_URI=""

EGIT_REPO_URI="git://github.com/dotcloud/docker.git"
if [[ ${PV} == *9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

inherit bash-completion-r1 git-2 linux-info systemd user

LICENSE="Apache-2.0"
SLOT="0"
IUSE="aufs +device-mapper doc vim-syntax"

CDEPEND="
	>=dev-db/sqlite-3.7.9:3
	device-mapper? (
		sys-fs/lvm2[thin]
	)
"
DEPEND="
	${CDEPEND}
	>=dev-lang/go-1.1.2
	dev-vcs/git
	dev-vcs/mercurial
	doc? (
		dev-python/sphinx
		dev-python/sphinxcontrib-httpdomain
	)
"
RDEPEND="
	${CDEPEND}
	!app-emulation/docker-bin
	>=app-arch/tar-1.26
	>=sys-apps/iproute2-3.5
	>=net-firewall/iptables-1.4
	>=app-emulation/lxc-0.8
	>=dev-vcs/git-1.7
	>=app-arch/xz-utils-4.9
	aufs? (
		|| (
			sys-fs/aufs3
			sys-kernel/aufs-sources
		)
	)
"

RESTRICT="strip"

pkg_setup() {
	CONFIG_CHECK+="
		~BRIDGE
		~MEMCG_SWAP
		~NETFILTER_XT_MATCH_ADDRTYPE
		~NF_NAT
		~NF_NAT_NEEDED
	"
	ERROR_MEMCG_SWAP="MEMCG_SWAP is required if you wish to limit swap usage of containers"

	if use aufs; then
		CONFIG_CHECK+="
			~AUFS_FS
		"
		ERROR_AUFS_FS="AUFS_FS is required to be set if and only if aufs-sources are used"
	fi

	if use device-mapper; then
		CONFIG_CHECK+="
			~BLK_DEV_DM
			~DM_THIN_PROVISIONING
			~EXT4_FS
		"
	fi

	check_extra_config
}

src_unpack() {
	git-2_src_unpack
}

src_compile() {
	export GOPATH="${WORKDIR}/gopath"
	mkdir -p "$GOPATH" || die

	# make sure docker itself is in our shiny new GOPATH
	mkdir -p "${GOPATH}/src/github.com/dotcloud" || die
	ln -sf "$(pwd -P)" "${GOPATH}/src/github.com/dotcloud/docker" || die

	# we need our vendored deps, too
	export GOPATH="$GOPATH:$(pwd -P)/vendor"

	# Gentoo doesn't set this up right yet
	export CGO_CFLAGS="-I${ROOT}/usr/include"
	export CGO_LDFLAGS="-L${ROOT}/usr/lib"

	# time to build!
	./hack/make.sh dynbinary || die

	if use doc; then
		emake -C docs docs man || die
	fi
}

src_install() {
	VERSION=$(cat VERSION)
	newbin bundles/$VERSION/dynbinary/docker-$VERSION docker
	exeinto /usr/libexec/docker
	newexe bundles/$VERSION/dynbinary/dockerinit-$VERSION dockerinit

	newinitd contrib/init/openrc/docker.initd docker
	newconfd contrib/init/openrc/docker.confd docker

	systemd_dounit contrib/init/systemd/docker.service

	dodoc AUTHORS CONTRIBUTING.md CHANGELOG.md NOTICE README.md
	if use doc; then
		dohtml -r docs/_build/html/*
		doman docs/_build/man/*
	fi

	dobashcomp contrib/completion/bash/*

	insinto /usr/share/zsh/site-functions
	doins contrib/completion/zsh/*

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles
		doins -r contrib/vim-syntax/ftdetect
		doins -r contrib/vim-syntax/syntax
	fi

	insinto /usr/share/${P}/contrib
	doins contrib/README
	cp -R "${S}/contrib"/* "${D}/usr/share/${P}/contrib/"
}

pkg_postinst() {
	elog ""
	elog "To use docker, the docker daemon must be running as root. To automatically"
	elog "start the docker daemon at boot, add docker to the default runlevel:"
	elog "  rc-update add docker default"
	elog "Similarly for systemd:"
	elog "  systemctl enable docker.service"
	elog ""

	# create docker group if the code checking for it in /etc/group exists
	enewgroup docker

	elog "To use docker as a non-root user, add yourself to the docker group."
	elog ""

	ewarn ""
	ewarn "If you want your containers to have access to the public internet or even"
	ewarn "the existing private network, IP Forwarding must be enabled:"
	ewarn "  sysctl -w net.ipv4.ip_forward=1"
	ewarn "or more permanently:"
	ewarn "  echo net.ipv4.ip_forward = 1 > /etc/sysctl.d/${PN}.conf"
	ewarn "Please be mindful of the security implications of enabling IP Forwarding."
	ewarn ""
}
