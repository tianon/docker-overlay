# docker-overlay

## what is docker?

See [the docker homepage](http://docker.io) and [the docker repository](https://github.com/dotcloud/docker) for more information about docker.

In a nutshell:
> Docker is an open-source project to easily create lightweight, portable, self-sufficient containers from any application.

## using this overlay

Check out [the Gentoo Linux installation instructions at docker.io](http://docs.docker.io/en/latest/installation/gentoolinux/) for important notes and direction regarding this overlay and the ebuilds contained within.

This repository is currently listed with layman.  Ensure that you have layman (`emerge -av app-portage/layman`), and invoke the following:

	layman -a docker

After adding this overlay, `app-emulation/docker` should be available for emerge (or alternatively, `app-emulation/docker-bin`):

	emerge -av app-emulation/docker
