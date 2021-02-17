# VERFILES := $(wildcard versions/*)
# VERSIONS := $(VERFILES:versions/%=%)

VERSIONS := $(shell awk -e '{print $1}' SSM-VERSIONS)
SED := "gsed"

all: ${VERSIONS}

%:
	@if [[ "$@" != "all" ]]; then \
		$(CURDIR)/build.sh $@; \
	fi

.DEFAULT_GOAL := all
.PHONY = all

