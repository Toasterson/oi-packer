// Link list
// https://github.com/omniosorg/kayak/blob/master/build/ami
// https://github.com/omniosorg/kayak/blob/master/lib/hvm_help.sh
// https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
// https://github.com/OpenFlowLabs/ec2-instance-metadata-rs
// https://www.packer.io/docs/post-processors/shell-local/
// https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html
// https://docs.aws.amazon.com/marketplace/latest/userguide/product-submission.html
// https://github.com/EugenMayer/opnsense-starterkit/issues/2
//


variable "oi_version" {
  type = string
  default = "20200504"
}

variable "iso_checksum" {
  type = string
  default = "99b34985b88ef301f4836fcc0a06a255821e6c4180e6bbe2ad293d795d63fda4"
}

variable "ssh_username" {
  type = string
  default = "root"
}

variable "vagrant_ssh_password" {
  type = string
  default = "vagrant"
}

variable "ami_ssh_password" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "build_version" {
  type = string
}

locals {
  iso_url = "http://dlc.openindiana.org/isos/hipster/${var.oi_version}/OI-hipster-text-${var.oi_version}.iso"
  boot_command_installer = [
    "47<enter><wait5>",
    "7<enter><wait5><wait5><wait5><wait5>",
    "1<enter><wait5>",
    "<f2><wait5>",
    "<f2><wait5>",
    "<right><wait5>",
    "<enter><wait5>",
  ]
  boot_command_installer_mbr = [
    "<down><wait5>",
    "<f2><wait5>",
    "<f2><wait5>",
  ]
  boot_command_installer_uefi = [
    "<f2><wait5>",
  ]
  boot_command_installer_net_and_time = [
    "<down><wait><down><wait><down><wait>",
    "<f2><wait5>",
    "<f2><wait5>",
    "<f2><wait5>",
  ]
  boot_command_installer_root_pw_vagrant = [
    "${var.vagrant_ssh_password}<tab>",
    "${var.vagrant_ssh_password}<tab>",
  ]
  boot_command_installer_root_pw_ami = [
    "${var.ami_ssh_password}<tab>",
    "${var.ami_ssh_password}<tab>",
  ]
  boot_command_installer_finish = [
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
  ]
  boot_command_installer_finish_login_ami = [
    "${var.ssh_username}<enter><wait>${var.ami_ssh_password}<enter><wait5>",
  ]
  boot_command_installer_finish_login_vagrant = [
    "${var.ssh_username}<enter><wait>${var.vagrant_ssh_password}<enter><wait5>",
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

source "qemu" "vagrant-box" {
  boot_command = concat(
  local.boot_command_installer,
  local.boot_command_installer_uefi,
  local.boot_command_installer_net_and_time,
  local.boot_command_installer_root_pw_vagrant,
  local.boot_command_installer_finish,
  local.boot_command_installer_finish_login_vagrant,
  local.boot_command_network_qemu,
  local.boot_command_initial_config
  )
  boot_wait = local.boot_wait
  disk_size = local.disk_size
  iso_checksum = var.iso_checksum
  iso_url =  local.iso_url
  iso_checksum_type = local.iso_checksum_type
  shutdown_command = local.shutdown_command
  ssh_username = var.ssh_username
  ssh_password = var.vagrant_ssh_password
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
}

source "virtualbox-iso" "vagrant-box" {
  boot_command = concat(
  local.boot_command_installer,
  local.boot_command_installer_uefi,
  local.boot_command_installer_net_and_time,
  local.boot_command_installer_root_pw_vagrant,
  local.boot_command_installer_finish,
  local.boot_command_installer_finish_login_vagrant,
  local.boot_command_network_virtualbox,
  local.boot_command_initial_config
  )
  boot_wait = local.boot_wait
  disk_size = local.disk_size
  iso_checksum = var.iso_checksum
  iso_url = local.iso_url
  iso_checksum_type = local.iso_checksum_type
  shutdown_command = local.shutdown_command
  ssh_username = var.ssh_username
  ssh_password = var.vagrant_ssh_password
  ssh_port = local.ssh_port
  output_directory = local.output_directory
  headless = local.headless
  guest_os_type = "OpenSolaris_64"
  hard_drive_interface = "sata"
  vboxmanage = [
    [ "modifyvm", "{{.Name}}", "--memory", "6144" ],
    [ "modifyvm", "{{.Name}}", "--cpus", "1" ],
    [ "modifyvm", "{{.Name}}", "--vram", "16" ],
    [ "modifyvm", "{{.Name}}", "--nictype1", "82545EM" ],
    [ "setextradata", "global", "GUI/SuppressMessages", "all" ]
  ]
}

source "virtualbox-iso" "ami-build" {
  boot_command = concat(
  local.boot_command_installer,
  local.boot_command_installer_mbr,
  local.boot_command_installer_net_and_time,
  local.boot_command_installer_root_pw_ami,
  local.boot_command_installer_finish,
  local.boot_command_installer_finish_login_ami,
  local.boot_command_network_virtualbox,
  local.boot_command_initial_config
  )
  boot_wait = local.boot_wait
  disk_size = local.disk_size
  iso_checksum = var.iso_checksum
  iso_url = local.iso_url
  iso_checksum_type = local.iso_checksum_type
  shutdown_command = local.shutdown_command
  ssh_username = var.ssh_username
  ssh_password = var.ami_ssh_password
  ssh_port = local.ssh_port
  output_directory = local.output_directory
  headless = local.headless
  guest_os_type = "OpenSolaris_64"
  hard_drive_interface = "sata"
  vboxmanage = [
    [ "modifyvm", "{{.Name}}", "--memory", "6144" ],
    [ "modifyvm", "{{.Name}}", "--cpus", "1" ],
    [ "modifyvm", "{{.Name}}", "--vram", "16" ],
    [ "modifyvm", "{{.Name}}", "--nictype1", "82545EM" ],
    [ "setextradata", "global", "GUI/SuppressMessages", "all" ]
  ]
  format = "ova"
}

source "qemu" "ami-build" {
  boot_command = concat(
  local.boot_command_installer,
  local.boot_command_installer_mbr,
  local.boot_command_installer_net_and_time,
  local.boot_command_installer_root_pw_ami,
  local.boot_command_installer_finish,
  local.boot_command_installer_finish_login_ami,
  local.boot_command_network_qemu,
  local.boot_command_initial_config
  )
  boot_wait = local.boot_wait
  disk_size = local.disk_size
  iso_checksum = var.iso_checksum
  iso_url =  local.iso_url
  iso_checksum_type = local.iso_checksum_type
  shutdown_command = local.shutdown_command
  ssh_username = var.ssh_username
  ssh_password = var.ami_ssh_password
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
}

build {
  sources = [
    "source.qemu.ami-build",
  ]

  provisioner "shell" {
    scripts = [
      "scripts/update.sh",
      "scripts/cleanup.sh",
      "scripts/ami.sh",
    ]
    expect_disconnect = true
  }

//  post-processor "amazon-import" {
//    access_key = var.aws_access_key
//    secret_key = var.aws_secret_key
//    region = var.aws_region
//    s3_bucket_name = "illumosimport"
//    ami_description = "OpenIndiana AMI Build"
//    ami_name = "OpenIndiana v${var.build_version}"
//    format = "ova"
//    license_type = "BYOL"
//    tags = {
//      Description = "OpenIndiana official AMI build ${var.oi_version}"
//    }
//  }

}

//build {
//  sources = [
//    "source.virtualbox-iso.vagrant-box",
//  ]
//
//  provisioner "shell" {
//    scripts = [
//      "scripts/update.sh",
//      "scripts/virtualbox-vmtools.sh",
//      "scripts/vagrant.sh",
//      "scripts/cleanup.sh"
//    ]
//    expect_disconnect = true
//  }
//
//  post-processor "vagrant" {
//    compression_level = 9
//    output = "OI-hipster-${var.build_version}-{{.Provider}}.box"
//  }
//}
//
//build {
//  sources = [
//    "source.qemu.vagrant-box"
//  ]
//
//  provisioner "shell" {
//    script = [
//          "scripts/update.sh",
//          "scripts/vagrant.sh",
//          "scripts/cleanup.sh",
//          "scripts/cleanup-qemu.sh"
//    ]
//    expect_disconnect = true
//  }
//
//  post-processor "vagrant" {
//    compression_level = 9
//    output = "OI-hipster-${var.build_version}-{{.Provider}}.box"
//  }
//}