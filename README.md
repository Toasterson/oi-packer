# oi-packer

This repository holds tools necesearry to build OpenIndiana [Vagrant](https://www.vagrantup.com/) boxes.

## Requierements
To build OpenIndiana Vagrant boxes, we need the following tools:

* [packer](https://www.packer.io/)
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/) (for testing built boxes)

Please note, that box building works only on platforms where packer runs.

## Quickstart

* Download Packer from the official [download site](https://www.packer.io/downloads.html). Select a version for your platform. We recommend to use the latest version.
* Download Vagrant from the official [download site](https://www.vagrantup.com/downloads.html). Select a version for your platform. We recommend to use the latest version.
* Download VirtualBox from the official [download site](https://www.virtualbox.org/wiki/Downloads). We recommend to  always use the latest VirtualBox.
* Run the following commands:

```bash
git clone https://github.com/OpenIndiana/oi-packer.git && \
cd oi-packer && \
packer build hipster.pkr.hcl
```

## Testing built boxes

After packer has finished building the box, there will be a Vagrant box file created, e.g. **OI-hipster-20200504-virtualbox.box**.
To test it, run following commands:

```bash
vagrant box add -n hipster-test-virtualbox OI-hipster-20200504-virtualbox.box
vagrant init hipster-test-virtualbox
vagrant up
```

```bash
vagrant box add -n hipster-test-libvirt OI-hipster-20200504-libvirt.box
vagrant init hipster-test-libvirt
vagrant up --provider=libvirt
```

## Release commands
If you are logged in to vagrant cloud use this commands to upload the built boxes.
```bash
REPO="openindiana/hipster"
VERSION="2020.05.04"
vagrant cloud publish -r $REPO $VERSION libvirt OI-hipster-20200504-libvirt.box
vagrant cloud publish -r $REPO $VERSION virtualbox OI-hipster-20200504-virtualbox.box
```

## Future improvements:

* Provide packer manifest and infrastructure for building VMWare images.
* Provide packer manifest and infrastructure for building Amazon images.
