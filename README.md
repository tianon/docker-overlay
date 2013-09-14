# docker-overlay

## what is docker?

See [the docker homepage](http://docker.io) and [the docker repository](https://github.com/dotcloud/docker) for more information about docker.

In a nutshell:
> Docker is an open-source project to easily create lightweight, portable, self-sufficient containers from any application.

## using this overlay

Check out [the Gentoo Linux installation instructions at docker.io](http://docs.docker.io/en/latest/installation/gentoolinux/) for important notes and direction regarding this overlay and the ebuilds contained within.

Add `https://raw.github.com/tianon/docker-overlay/master/repositories.xml` to the `overlays` section in `/etc/layman/layman.cfg` (as per instructions on the [Gentoo Wiki](http://wiki.gentoo.org/wiki/Layman#Adding_custom_overlays)), then invoke the following:

	layman -f -a docker

After performing those steps, `app-emulation/docker` should be available for emerge (or alternatively, `app-emulation/docker-bin`):

	emerge -av app-emulation/docker
