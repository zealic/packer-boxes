# Build for Packer
BASE_NAME=centos-7-vmlord

build:
	packer build $(BASE_NAME).json

push:
	packer push -var-file=variables.json $(BASE_NAME).json

.PHONY: build push
