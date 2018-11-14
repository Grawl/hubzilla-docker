# Deploy Hubzilla with Docker

## Overview

Docker makes deploying a [Hubzilla](http://hubzilla.org) server, or "hub", as simple as it gets. Three Docker containers are created using the docker-compose system. One container runs [Traefik](http://traefik.io), which acts as a reverse proxy and an automatic installer for your hub's [LetsEncrypt](http://letsencrypt.org) SSL certificate. Another container runs the MySQL database. The third container runs the webserver and the Hubzilla instance.

## Requirements

All you need is a Linux host machine with [docker-compose](https://docs.docker.com/compose/) installed. It is recommended to run Docker as a non-root user, who is added to the `docker` group.

## Instructions

1. Clone this repository to a folder such as `/opt/hubzilla-docker/`.

1. Copy `hub.template.conf` to `hub.conf`.
```
cp conf/hub.template.conf conf/hub.conf
vi conf/hub.conf
```
Add the information about your SMTP server as well as the hub domain (`hub.example.com`) and the email address you want to use for the hub administrator account to `hub.conf`. The hub admin email will also be the email address used for the LetsEncrypt registration.

1. In the same folder execute the `bootstrap.sh` script, which applies your information to construct the `docker-compose.yml` file and launches the `docker-compose up` command that build and runs the containers:
```
bash bootstrap.sh
```

1. Open `https://hub.example.com/register` in a browser and register the hub admin account using the same email you entered in `hub.conf`. Email verification is disabled at this stage for convenience, so you should immediately be redirected to the new channel page, where you can create your first channel.
