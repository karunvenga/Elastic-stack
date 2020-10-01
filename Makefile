.PHONY: clean logging helm info lint

# export all env variables to sub-proc
.EXPORT_ALL_VARIABLES:

# CI variables
ifeq ($(CI),true)
$(info == Running in CI environment ===============)
else
$(info == Running in local environment ============)
CI_COMMIT_SHORT_SHA   ?= $(shell git rev-parse --short HEAD)
CI_COMMIT_SHA		  ?= $(shell git rev-parse HEAD)
CI_PROJECT_PATH		  ?= f5aas/$(shell cat PROJECT)
CI_PROJECT_NAME		  ?= $(shell cat PROJECT)
CI_COMMIT_REF_SLUG	  ?= develop
endif

VERSION 				 ?= $(shell cat VERSION)
SEMVERSION_CLI		     ?= $(GOPATH)/bin/semver-cli

$(info == BUILD VARS ==============================)
$(info VERSION=$(VERSION))
$(info CI_COMMIT_SHA=$(CI_COMMIT_SHA))
$(info CI_COMMIT_SHORT_SHA=$(CI_COMMIT_SHORT_SHA))
$(info )
$(info CI_PROJECT_PATH=$(CI_PROJECT_PATH))
$(info ============================================)


all: helm

info:
	@true

clean: ## remove dist folder
	rm -rf dist/*.tgz

lint: ## lint all helm packages
	helm --debug lint helm/elastic-stack

elastic-stack: ## build helm elastic-satck only
	mkdir -p dist
	helm --debug package --version "$(VERSION)" -d dist helm/elastic-stack


helm: clean lint elastic-stack ## build all helm packages


bump_patch: ## Bump the patch version
	$(ECHO) $(SEMVERSION_CLI) inc patch $$(cat VERSION) > VERSION && \
		git commit -m "New patch version $$(cat VERSION)" VERSION && \
		git tag -m "release of $$(cat VERSION) $$(date)" v$$(cat VERSION)

bump_minor: ## Bump the minor version
	$(ECHO) $(SEMVERSION_CLI) inc minor $$(cat VERSION) > VERSION && \
		git commit -m "New minor version $$(cat VERSION)" VERSION && \
		git tag -m "release of $$(cat VERSION) $$(date)" v$$(cat VERSION)

bump_major: ## Bump the major version
	$(ECHO) $(SEMVERSION_CLI) inc major $$(cat VERSION) > VERSION && \
		git commit -m "New major version $$(cat VERSION)" VERSION && \
		git tag -m "release of $$(cat VERSION) $$(date)" v$$(cat VERSION)

release: bump_patch ## Bumps the patch version, commits changes, pushes tags, and pushes changes.
	git push --tags
	git push


help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

