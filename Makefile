# VERSIONS := $(shell ./list_versions.sh)
VERSIONS := $(shell cat ci/SSM_VERSIONS)
TARGETS  := $(VERSIONS:%=target/amazon-ssm-agent-%-r0.apk)

DOCKER_IMAGE = 718758479978.dkr.ecr.ap-southeast-2.amazonaws.com/ssm-agent-alpine-build
APK_ROOT     = /root/packages/x86_64

.DEFAULT_GOAL := all
.PHONY: all clean purge ${VERSIONS} base-image

all: ${TARGETS}

%:
	@if [[ "$@" != "all"]; then \
		$(MAKE) target/amazon-ssm-agent-$@-r0.apk; \
	fi

target/amazon-ssm-agent-%-r0.apk: %
	docker stop ssmbuild-$< || true && docker rm ssmbuild-$< || true
	docker run --name ssmbuild-$< $(DOCKER_IMAGE) /data/build.sh $<
	docker cp ssmbuild-$<:$(APK_ROOT)/amazon-ssm-agent-$<-r0.apk $@
	docker rm ssmbuild-$<

build-base-image:
	docker build -t $(DOCKER_IMAGE):latest .

codebuild-base-image:
	./ci/codebuild-local.sh \
		-c -d \
		-i aws/codebuild/amazonlinux2-x86_64-standard:3.0 \
		-b ci/baseimage.yml \
		-a target/

codebuild-package-%: %
	$(eval tmpfile := $(shell mktemp))
	echo "SSM_VERSION=$<" > $(tmpfile)
	./ci/codebuild-local.sh \
		-c -d \
		-i aws/codebuild/amazonlinux2-x86_64-standard:3.0 \
		-b ci/package.yml \
		-a target/ \
		-e $(tmpfile)

prepare:
	docker pull $(DOCKER_IMAGE)
	mkdir -p target/

clean:
	rm -vfr APKBUILD target/

purge: clean
	docker rmi $(DOCKER_IMAGE)

