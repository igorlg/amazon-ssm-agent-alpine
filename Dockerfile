FROM alpine

WORKDIR /data

# Install dependencies
RUN apk update \
 && apk add abuild git curl bash sudo \
 && apk add make go

# Install rc-service so we can test the package
# This 'enables' the openrc in case /sbin/init wasn't the pid 1
RUN apk add openrc \
 && mkdir -p /run/openrc \
 && touch /run/openrc/softlevel


# Run building prep steps
RUN abuild-keygen -a -i -n \
 && mkdir -p -m 777 /var/cache/distfiles \
 && chgrp abuild /var/cache/distfiles

