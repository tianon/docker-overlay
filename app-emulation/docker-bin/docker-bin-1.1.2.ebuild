# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Docker complements kernel namespacing with a high-level API which operates at the process level."
HOMEPAGE="https://www.docker.io/"
SRC_URI="https://get.docker.io/ubuntu/pool/main/l/lxc-docker-${PV}/lxc-docker-${PV}_${PV}_amd64.deb"
KEYWORDS="-* ~amd64"

inherit unpacker linux-info systemd

LICENSE="Apache-2.0"
SLOT="0"
IUSE="aufs btrfs +device-mapper lxc"

DEPEND=""
RDEPEND="
	!app-emulation/docker
	>=net-firewall/iptables-1.4
	lxc? (
		>=app-emulation/lxc-1.0
	)
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

RESTRICT="installsources strip"

S="${WORKDIR}"

pkg_setup() {
	if kernel_is lt 3 8; then
		ewarn ""
		ewarn "Using Docker with kernels older than 3.8 is unstable and unsupported."
		ewarn ""
	fi

	# many of these were borrowed from the app-emulation/lxc ebuild
	CONFIG_CHECK+="
		~CGROUPS
		~CGROUP_CPUACCT
		~CGROUP_DEVICE
		~CGROUP_FREEZER
		~CGROUP_SCHED
		~CPUSETS
		~MEMCG_SWAP
		~RESOURCE_COUNTERS

		~IPC_NS
		~NAMESPACES
		~PID_NS

		~DEVPTS_MULTIPLE_INSTANCES
		~MACVLAN
		~NET_NS
		~UTS_NS
		~VETH

		~!NETPRIO_CGROUP
		~POSIX_MQUEUE

		~BRIDGE
		~IP_NF_TARGET_MASQUERADE
		~NETFILTER_XT_MATCH_ADDRTYPE
		~NETFILTER_XT_MATCH_CONNTRACK
		~NF_NAT
		~NF_NAT_NEEDED

		~!GRKERNSEC_CHROOT_CAPS
		~!GRKERNSEC_CHROOT_CHMOD
		~!GRKERNSEC_CHROOT_DOUBLE
		~!GRKERNSEC_CHROOT_MOUNT
		~!GRKERNSEC_CHROOT_PIVOT
	"

	ERROR_MEMCG_SWAP="CONFIG_MEMCG_SWAP: is required if you wish to limit swap usage of containers"

	for c in GRKERNSEC_CHROOT_MOUNT GRKERNSEC_CHROOT_DOUBLE GRKERNSEC_CHROOT_PIVOT GRKERNSEC_CHROOT_CHMOD; do
		declare "ERROR_$c"="CONFIG_$c: see app-emulation/lxc postinst notes for why some GRSEC features make containers unusuable"
	done

	if use aufs; then
		CONFIG_CHECK+="
			~AUFS_FS
		"
		ERROR_AUFS_FS="CONFIG_AUFS_FS: is required to be set if and only if aufs-sources are used"
	fi

	if use btrfs; then
		CONFIG_CHECK+="
			~BTRFS_FS
		"
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
}
