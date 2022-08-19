SHELL:=/bin/bash

# Temporary hack, until I can use the list_versions script.
VERSIONS := $(shell ./list_versions.sh)
LATEST_VERSION := $(shell ./list_versions.sh | head -1)
TARGETS  := $(VERSIONS:%=target/amazon-ssm-agent-%-r0.apk)

DOCKER_IMAGE = ssm-agent-alpine-build
APK_ROOT     = /root/packages/x86_64

.DEFAULT_GOAL := all
.PHONY: all clean purge $(VERSIONS)

all: $(VERSIONS)
latest: $(LATEST_VERSION)

versions:
	@echo "Latest version"
	@echo "$(LATEST_VERSION)"
	@echo ""
	@echo "Available versions to build:"
	@for i in $(VERSIONS); do echo $$i; done

$(TARGETS):%:
$(VERSIONS):%:target/amazon-ssm-agent-%-r0.apk
	mkdir -p target/ || true

	@echo "Building package $< for version $@"
	docker stop ssmbuild-$@ 2>/dev/null || true
	docker rm ssmbuild-$@ 2>/dev/null || true

	docker run --name ssmbuild-$@ $(DOCKER_IMAGE) /data/build.sh $@

	docker cp ssmbuild-$@:$(APK_ROOT)/amazon-ssm-agent-$@-r0.apk $<
	docker rm ssmbuild-$@
	@echo "DONE building package $<"

build-base-image:
	docker build -t $(DOCKER_IMAGE):latest .

clean:
	rm -vfr APKBUILD target/

purge: clean
	docker rmi $(DOCKER_IMAGE)
