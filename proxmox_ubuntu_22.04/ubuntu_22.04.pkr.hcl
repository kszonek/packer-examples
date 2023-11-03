packer {
  required_plugins {
    proxmox = {
      version = "= 1.1.5"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_node" {
  default = "pve01"
  type = string
}

variable "proxmox_password" {
  sensitive = true
  type = string
}

variable "proxmox_template_id" {
  default = null
  type    = string
}

variable "proxmox_template_name" {
  default = "ubuntu-22.04"
  type    = string
}

variable "proxmox_url" {
  type    = string
}

variable "proxmox_username" {
  type = string
}

variable "iso_file" {
  default = "ubuntu-22.04.3-live-server-amd64.iso"
  type    = string
}

source "proxmox-iso" "ubuntu" {
  insecure_skip_tls_verify = true
  proxmox_url = "https://${var.proxmox_url}/api2/json"
  username = "${var.proxmox_username}"
  password = "${var.proxmox_password}"
  node = "${var.proxmox_node}"

  template_name = "${var.proxmox_template_name}"
  template_description = "packer generated template, installed from ${var.iso_file}"
  vm_id = "${var.proxmox_template_id}"

  cloud_init = true
  cloud_init_storage_pool = "local-lvm"
  cpu_type = "host"
  cores = 4
  memory = 4096
  onboot = true
  qemu_agent = true
  disks {
    disk_size = "20G"
    storage_pool = "local-lvm"
    type = "scsi"
  }
  network_adapters {
    bridge = "vmbr0"
    model = "virtio"
  }

  iso_file = "local:iso/${var.iso_file}"
  unmount_iso = true
  boot_command = ["c", "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ", "<enter><wait>", "initrd /casper/initrd<enter><wait>", "boot<enter>"]
  http_directory = "http"
  boot_wait = "5s"

  ssh_username = "packer"
  ssh_password = "this_default_password_is_not_working"
  ssh_timeout = "20m"
}

build {
  sources = ["proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }

  provisioner "shell" {
    inline = ["echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
              "sudo apt-get update",
              "sudo apt-get -y upgrade",
              "sudo install -m 0755 -d /etc/apt/keyrings"]
  }

  // Uncomment to install docker
  // provisioner "shell" {
  //   inline = ["curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
  //             "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
  //             "echo deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable | sudo tee /etc/apt/sources.list.d/docker.list",
  //             "sudo apt-get update",
  //             "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"]
  // }

  // Uncomment to install packer
  // provisioner "shell" {
  //   inline = ["curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg",
  //             "sudo chmod a+r /etc/apt/keyrings/hashicorp.gpg",
  //             "echo deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main | sudo tee /etc/apt/sources.list.d/hashicorp.list",
  //             "sudo apt-get update",
  //             "sudo apt-get install -y packer"]
  // }

  provisioner "shell" {
    inline = ["sudo rm /etc/ssh/ssh_host_*",
              "sudo truncate -s 0 /etc/machine-id",
              "sudo apt-get -y autoremove --purge",
              "sudo apt-get -y clean",
              "sudo rm -rf /var/lib/apt/lists/*",
              "sudo cloud-init clean",
              "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
              "sudo sync"]
  }
}
