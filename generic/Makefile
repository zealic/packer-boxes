# Build for Packer
BASE_NAME := centos-7-$(shell basename `pwd`)
RELEASE_VERSION := $(shell cat ../VERSION)

build: cleanup
	@packer build -var RELEASE_VERSION=0.0.0 -var-file=../variables-local.json -only=local $(BASE_NAME).json

push:
	@sed 's/{{user `RELEASE_VERSION`}}/'${RELEASE_VERSION}'/g' $(BASE_NAME).json > $(BASE_NAME).generated.json
	@packer push -var VERSION=$(RELEASE_VERSION) $(BASE_NAME).generated.json
	@rm  $(BASE_NAME).generated.json

cleanup:
	@if [ -d output-local ]; then \
	  rm -r output-local; \
	fi

.PHONY: build push cleanup
