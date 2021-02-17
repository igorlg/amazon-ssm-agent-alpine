FROM alpine

WORKDIR /data

# Install dependencies
RUN apk update && \
	apk add make && \
	apk add abuild && \
	apk add sudo && \
	# amazon-ssm-agent runs some bash scripts
	apk add bash

# Install rc-service so we can test the package
RUN apk add openrc && \
    # This 'enables' the openrc in case /sbin/init wasn't the pid 1
    mkdir -p /run/openrc && \
    touch /run/openrc/softlevel


# Run building prep steps
RUN	abuild-keygen -a -i -n && \
    mkdir -p -m 777 /var/cache/distfiles && \
    	chgrp abuild /var/cache/distfiles
