# Warning do not run this makefile roughly 20 minutes before midnight.
BUILD_VERSION=$(shell date +%Y%m)
VAGRANT=vagrant
REPO="openindiana/hipster"
PACKER=packer

.PHONY: build test all publish release

test: test-virtualbox test-libvirt

all: build test

release: build publish

publish: publish-virtualbox publish-libvirt

build: OI-hipster-$(BUILD_VERSION)-virtualbox.box OI-hipster-$(BUILD_VERSION)-libvirt.box

init:
	$(PACKER) init -upgrade hipster.pkr.hcl

OI-hipster-$(BUILD_VERSION)-virtualbox.box: init
	$(PACKER) build -only=virtualbox-iso.oi-hipster -var "build_version=$(BUILD_VERSION)" -parallel-builds=1 hipster.pkr.hcl

OI-hipster-$(BUILD_VERSION)-libvirt.box: init
	$(PACKER) build -only=qemu.oi-hipster -var "build_version=$(BUILD_VERSION)" -parallel-builds=1 hipster.pkr.hcl

test-%: OI-hipster-$(BUILD_VERSION)-%.box
	$(VAGRANT) box add --force --name hipster-test-$(*) "OI-hipster-$(BUILD_VERSION)-$(*).box"
	rm -f Vagrantfile
	$(VAGRANT) init hipster-test-$(*)
	$(VAGRANT) up --provider=$(*)
	echo "Please test this box and disconnect once done."
	$(VAGRANT) ssh
	$(VAGRANT) destroy --force
	$(VAGRANT) box remove --force hipster-test-$(*)
	rm Vagrantfile
	touch test-$(*)

publish-%: OI-hipster-$(BUILD_VERSION)-%.box
	vagrant cloud publish -r "$(REPO)" "$(BUILD_VERSION)" $(*) "OI-hipster-$(BUILD_VERSION)-$(*).box"
	touch publish-$(*)

clean:
	rm -rf OI-hipster-$(BUILD_VERSION)-libvirt.box OI-hipster-$(BUILD_VERSION)-virtualbox.box test-libvirt test-virtualbox publish-libvirt publish-virtualbox Vagrantfile output
