SHELL:=/bin/bash

# Temporary hack, until I can use the list_versions script.
VERSIONS := $(shell ./list_versions.sh)
TARGETS  := $(VERSIONS:%=target/amazon-ssm-agent-%-r0.apk)

DOCKER_IMAGE = 718758479978.dkr.ecr.ap-southeast-2.amazonaws.com/718758479978.dkr.ecr.ap-southeast-2.amazonaws.com/ssm-agent-alpine--agent-alpine-build
APK_ROOT     = /root/packages/x86_64

.DEFAULT_GOAL := all
.PHONY: all clean purge $(VERSIONS)

all: $(VERSIONS)

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
