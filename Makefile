.PHONY: prepare build install clean

prepare:
	apk update
	apk add abuild
	abuild-keygen -a -i -n
	mkdir -p -m 777 /var/cache/distfiles
	chgrp abuild /var/cache/distfiles

build: clean
	abuild -r

clean:
	rm -rf src/ $HOME/packages/alpine/x86_64/amazon-ssm-agent-*
	rm -rf /var/cache/distfiles/amazon-ssm-agent-*

install:
	apk add $HOME/packages/alpine/x86_64/amazon-ssm-agent-*
