# what is docker?

See [the docker homepage](http://docker.io) and [the docker repository](https://github.com/dotcloud/docker) for more information about docker.

# using this overlay

Be sure to check out http://docs.docker.io/en/latest/installation/gentoolinux/ for more notes and instructions regarding this overlay and ebuilds.

Add `https://raw.github.com/tianon/docker-overlay/master/repositories.xml` to the `overlays` section in `/etc/layman/layman.cfg` (as per instructions on the [Gentoo Wiki](http://wiki.gentoo.org/wiki/Layman#Adding_custom_overlays)), then invoke the following:

	layman -f -a docker

After performing those steps, the following should work (or any other package from this overlay):

	sudo emerge -av app-emulation/docker
