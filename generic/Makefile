# Build for Packer
BASE_NAME := centos-7-$(shell basename `pwd`)

build: cleanup
	@packer build -var-file=../variables-common.json -var-file=../variables-local.json $(BASE_NAME).json

push:
	@packer push -var-file=../variables-common.json $(BASE_NAME).json

cleanup:
	@if [ -d output-vbox ]; then \
	  rm -r output-vbox; \
	fi

.PHONY: build push cleanup
