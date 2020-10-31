# VERFILES := $(wildcard versions/*)
# VERSIONS := $(VERFILES:versions/%=%)

VERSIONS := $(shell cat SSM-VERSIONS)
SED := "gsed"

all: ${VERSIONS}

%:
	@if [[ "$@" != "all" ]]; then \
		echo "Building package version $@"; \
		sed -e 's/SED_PKGVER/$@/g' -e "s/SED_PKGSUM/" APKBUILD.template > APKBUILD; \
		grep "^pkgver" APKBUILD; \
	fi

prepare:
	sudo addgroup alpine abuild
	apk update
	apk add abuild
	abuild-keygen -a -i -n
	mkdir -p -m 777 /var/cache/distfiles
	chgrp abuild /var/cache/distfiles

clean:
	rm -rf src/ build/

.DEFAULT_GOAL := all
.PHONY = all

