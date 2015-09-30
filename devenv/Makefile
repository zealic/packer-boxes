# Build for Packer
BASE_NAME := centos-7-$(shell basename `pwd`)
RELEASE_VERSION := $(shell cat ../VERSION)

build: cleanup
	@packer build -var-file=../variables-local.json -only=local $(BASE_NAME).json

push:
	@packer push -var VERSION=$(RELEASE_VERSION) $(BASE_NAME).json

cleanup:
	@if [ -d output-local ]; then \
	  rm -r output-local; \
	fi

.PHONY: build push cleanup
