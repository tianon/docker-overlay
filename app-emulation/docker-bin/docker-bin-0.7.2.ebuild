# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Docker complements LXC with a high-level API which operates at the process level."
HOMEPAGE="http://www.docker.io/"
SRC_URI="https://get.docker.io/ubuntu/pool/main/l/lxc-docker-${PV}/lxc-docker-${PV}_${PV}_amd64.deb"
KEYWORDS="-* ~amd64"

inherit unpacker linux-info systemd

LICENSE="Apache-2.0"
SLOT="0"
IUSE="aufs +device-mapper"

DEPEND=""
RDEPEND="
	!app-emulation/docker
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
	device-mapper? (
		sys-fs/lvm2[thin]
	)
"

RESTRICT="strip"

S="${WORKDIR}"

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

src_install() {
	dobin usr/bin/docker

	newinitd "${FILESDIR}/docker-r3.initd" docker
	newconfd "${FILESDIR}/docker-r3.confd" docker

	systemd_dounit "${FILESDIR}/docker.service"
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
