VERSIONS := $(shell ./list_versions.sh)
TARGETS  := $(VERSIONS:%=target/amazon-ssm-agent-%-r0.apk)

DOCKER_IMAGE = 718758479978.dkr.ecr.ap-southeast-2.amazonaws.com/ssm-agent-alpine-build
APK_ROOT     = /root/packages/x86_64

.DEFAULT_GOAL := all
.PHONY: all clean purge ${VERSIONS}

all: ${TARGETS}

target/amazon-ssm-agent-%-r0.apk: %
	docker run --name ssmbuild-$< $(DOCKER_IMAGE) /data/build.sh $<
	docker cp ssmbuild-$<:$(APK_ROOT)/amazon-ssm-agent-$<-r0.apk $@
	docker rm ssmbuild-$<

prepare:
	docker pull $(DOCKER_IMAGE)
	mkdir -p target/

clean:
	rm -vfr APKBUILD target/

purge: clean
	docker rmi $(DOCKER_IMAGE)

