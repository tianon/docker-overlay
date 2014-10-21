# docker-overlay

## what is docker?

See [the Docker homepage](http://docker.io) and [the Docker repository](https://github.com/dotcloud/docker) for more information about Docker.

In a nutshell:
> Docker is an open-source project to easily create lightweight, portable, self-sufficient containers from any application.

## using docker in gentoo

Latest stable is in the portage tree proper under the name `app-emulation/docker`.  If you just want the latest release version of Docker, that's the best place to find it.

Be sure to check out [the Gentoo Linux installation instructions at docker.io](http://docs.docker.io/en/latest/installation/gentoolinux/) for important notes and direction regarding the Gentoo ebuilds for Docker.

## using this overlay

If you want a `-bin` ebuild, the latest and greatest changes before they're pushed to tree, or a live ebuild, you're in the correct place.

This repository is listed with layman.  Ensure that you have layman (`emerge -av app-portage/layman`), and invoke the following:

	layman -a docker

After adding this overlay, `app-emulation/docker` should be available for emerge (or alternatively, `app-emulation/docker-bin`):

	emerge -av app-emulation/docker

Note also the existence of `dev-util/gordon` (see https://github.com/docker/gordon for more details).
