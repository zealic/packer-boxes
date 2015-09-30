# Build for Packer
BASE_NAME=centos-7-vmlord

build:
	packer build -var-file=../variables-common.json -var-file=../variables-local.json ../$(BASE_NAME).json

push:
	packer push -var-file=../variables-common.json $(BASE_NAME).json

.PHONY: build push
