variable "build_version" {
  type = string
  default = "20210430"
}

variable "iso_version" {
  type = string
  default = "20210430"
}

variable "iso_checksum" {
  type = string
  default = "aa20966d6b6fd4d7651683305f21c6b315ca4c5a69b940a8a02fbbb6ccba121e"
}

variable "ssh_username" {
  type = string
  default = "root"
}

variable "ssh_password" {
  type = string
  default = "vagrant"
}

locals {
  iso_url = "http://dlc.openindiana.org/isos/hipster/${var.iso_version}/OI-hipster-text-${var.iso_version}.iso"
  boot_command_installer = [
    "47<enter><wait5>",
    "7<enter><wait5><wait5><wait5><wait5>",
    "1<enter><wait5>",
    "<f2><wait5>",
    "<f2><wait5>",
    "<right><wait5>",
    "<enter><wait5>",
    "<f2><wait5>",
    "<down><wait><down><wait><down><wait>",
    "<f2><wait5>",
    "<f2><wait5>",
    "<f2><wait5>",
    "vagrant<tab>",
    "vagrant<tab>",
    "<f2><wait5>",
    "<f2><wait5>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<f8><wait>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "<wait10><wait10><wait10><wait10><wait10><wait10>",
    "${var.ssh_username}<enter><wait>${var.ssh_password}<enter><wait5>",
  ]
  boot_command_network_virtualbox = [
    "ipadm create-if e1000g0<enter><wait>",
    "ipadm create-addr -T dhcp e1000g0/v4<enter><wait>",
  ]
  boot_command_network_qemu = [
    "ipadm create-if vioif0<enter><wait>",
    "ipadm create-addr -T dhcp vioif0/v4<enter><wait>",
  ]
  boot_command_initial_config = [
    "echo 'nameserver 8.8.8.8' > /etc/resolv.conf<enter><wait>",
    "cp /etc/nsswitch.dns /etc/nsswitch.conf<enter><wait>",
    "sed -i -e 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config<enter><wait>",
    "svcadm restart ssh<enter><wait>"
  ]
  shutdown_command = "/usr/sbin/shutdown -g 0 -y -i 5"
  iso_checksum_type = "sha256"
  disk_size = 51200
  boot_wait = "30s"
  headless = true
  ssh_port = 22
  output_directory = "output"
}

source "qemu" "oi-hipster" {
  boot_command = concat(
  local.boot_command_installer,
  local.boot_command_network_qemu,
  local.boot_command_initial_config
  )
  boot_wait = local.boot_wait
  disk_size = local.disk_size
  iso_checksum = var.iso_checksum
  iso_url =  local.iso_url
  shutdown_command = local.shutdown_command
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_port = local.ssh_port
  output_directory = local.output_directory
  headless = local.headless
  accelerator = "kvm"
  format = "qcow2"
  net_device = "virtio-net"
  disk_interface = "virtio"
  vnc_bind_address = "127.0.0.1"
  qemuargs = [
    ["-m", "4096"],
    ["-cpu", "qemu64,+xsave"]
  ]
  http_directory = "scripts"
}

build {
  source "source.qemu.oi-hipster" {	
    vm_name = "openindiana-cloud-image-generic"
  }

  provisioner "shell" {
    script = "scripts/update.sh"
    expect_disconnect = true
  }

  provisioner "shell" {
    script = "scripts/cloud-init.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup-qemu.sh"
  }

  post-processor "compress" {
    output = "openindiana-cloud-image-generic.qcow2.lz4"
  }
}
