# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Docker complements kernel namespacing with a high-level API which operates at the process level"
HOMEPAGE="https://www.docker.com"
SRC_URI="https://get.docker.com/ubuntu/pool/main/l/lxc-docker-${PV}/lxc-docker-${PV}_${PV}_amd64.deb"
KEYWORDS="-* ~amd64"

inherit unpacker linux-info systemd

LICENSE="Apache-2.0"
SLOT="0"
IUSE="aufs btrfs +device-mapper lxc overlay"

DEPEND=""
# https://github.com/docker/docker/blob/master/hack/PACKAGERS.md#runtime-dependencies
# https://github.com/docker/docker/blob/master/hack/PACKAGERS.md#optional-dependencies
RDEPEND="
	!app-emulation/docker
	>=net-firewall/iptables-1.4
	sys-process/procps
	>=dev-vcs/git-1.7
	>=app-arch/xz-utils-4.9

	lxc? (
		>=app-emulation/lxc-1.0.7
	)
	aufs? (
		|| (
			sys-fs/aufs3
			sys-kernel/aufs-sources
		)
	)
"

RESTRICT="installsources strip"

S="${WORKDIR}"

# see "contrib/check-config.sh" from upstream's sources
CONFIG_CHECK="
	NAMESPACES NET_NS PID_NS IPC_NS UTS_NS
	DEVPTS_MULTIPLE_INSTANCES
	CGROUPS CGROUP_CPUACCT CGROUP_DEVICE CGROUP_FREEZER CGROUP_SCHED
	MACVLAN VETH BRIDGE
	NF_NAT_IPV4 IP_NF_FILTER IP_NF_TARGET_MASQUERADE
	NETFILTER_XT_MATCH_ADDRTYPE NETFILTER_XT_MATCH_CONNTRACK
	NF_NAT NF_NAT_NEEDED

	POSIX_MQUEUE

	~MEMCG_SWAP
	~RESOURCE_COUNTERS
	~CGROUP_PERF
"

ERROR_MEMCG_SWAP="CONFIG_MEMCG_SWAP: is required if you wish to limit swap usage of containers"
ERROR_RESOURCE_COUNTERS="CONFIG_RESOURCE_COUNTERS: is optional for container statistics gathering"
ERROR_CGROUP_PERF="CONFIG_CGROUP_PERF: is optional for container statistics gathering"

pkg_setup() {
	if kernel_is lt 3 8; then
		eerror ""
		eerror "Using Docker with kernels older than 3.8 is unstable and unsupported."
		eerror " - http://docs.docker.com/installation/binaries/#check-kernel-dependencies"
		die 'Kernel is too old - need 3.8 or above'
	fi

	# for where these kernel versions come from, see:
	# https://www.google.com/search?q=945b2b2d259d1a4364a2799e80e8ff32f8c6ee6f+site%3Akernel.org%2Fpub%2Flinux%2Fkernel+file%3AChangeLog*
	if ! {
		kernel_is ge 3 16 \
		|| { kernel_is 3 15 && kernel_is ge 3 15 5; } \
		|| { kernel_is 3 14 && kernel_is ge 3 14 12; } \
		|| { kernel_is 3 12 && kernel_is ge 3 12 25; }
	}; then
		ewarn ""
		ewarn "There is a serious Docker-related kernel panic that has been fixed in 3.16+"
		ewarn "  (and was backported to 3.15.5+, 3.14.12+, and 3.12.25+)"
		ewarn ""
		ewarn "See also https://github.com/docker/docker/issues/2960"
	fi

	if use aufs; then
		CONFIG_CHECK+="
			~AUFS_FS
		"
		# TODO there must be a way to detect "sys-kernel/aufs-sources" so we don't warn "sys-fs/aufs3" users about this
		# an even better solution would be to check if the current kernel sources include CONFIG_AUFS_FS as an option, but that sounds hairy and error-prone
		ERROR_AUFS_FS="CONFIG_AUFS_FS: is required to be set if and only if aufs-sources are used"
	fi

	if use btrfs; then
		CONFIG_CHECK+="
			~BTRFS_FS
		"
	fi

	if use device-mapper; then
		CONFIG_CHECK+="
			~BLK_DEV_DM ~DM_THIN_PROVISIONING ~EXT4_FS
		"
	fi

	if use overlay; then
		CONFIG_CHECK+="
			~OVERLAY_FS ~EXT4_FS_SECURITY ~EXT4_FS_POSIX_ACL
		"
	fi

	linux-info_pkg_setup
}

src_install() {
	dobin usr/bin/docker

	newinitd "${FILESDIR}/docker-r3.initd" docker
	newconfd "${FILESDIR}/docker-r3.confd" docker

	systemd_dounit "${FILESDIR}/docker.service"
}

pkg_postinst() {
	elog ""
	elog "To use Docker, the Docker daemon must be running as root. To automatically"
	elog "start the Docker daemon at boot, add Docker to the default runlevel:"
	elog "  rc-update add docker default"
	elog "Similarly for systemd:"
	elog "  systemctl enable docker.service"
	elog ""

	# create docker group if the code checking for it in /etc/group exists
	enewgroup docker

	elog "To use Docker as a non-root user, add yourself to the 'docker' group:"
	elog "  usermod -aG docker youruser"
	elog ""
}
