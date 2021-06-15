FROM alpine AS build

WORKDIR /data

# Install dependencies
RUN apk update \
 && apk add make abuild sudo go git build-base

# amazon-ssm-agent runs some bash scripts
RUN apk add bash

# This 'enables' the openrc in case /sbin/init wasn't the pid 1
RUN apk add openrc \
 && mkdir -p /run/openrc \
 && touch /run/openrc/softlevel

# Run building prep steps
RUN abuild-keygen -a -i -n \
 && mkdir -p -m 777 /var/cache/distfiles \
 && chgrp abuild /var/cache/distfiles

COPY APKBUILD.template               /data/
COPY amazon-ssm-agent.post-install   /data/
COPY amazon-ssm-agent.post-upgrade   /data/
COPY amazon-ssm-agent.pre-deinstall  /data/
COPY amazon-ssm-agent.pre-upgrade    /data/
COPY amazon-ssm.rc-service           /data/
COPY build.sh                        /data/
COPY templates/                      /data/templates/

