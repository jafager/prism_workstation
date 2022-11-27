terraform {
    required_providers {
        libvirt = {
            source = "dmacvicar/libvirt"
        }
    }
}

provider "libvirt" {
    uri = "qemu:///system"
}

resource "libvirt_network" "mklab" {
    name = "mklab"
    mode = "nat"
    domain = "mklab.prism.local"
    addresses = ["192.168.254.0/24"]
}

resource "libvirt_pool" "mklab" {
    name = "mklab"
    type = "dir"
    path = "/mnt/libvirt/mklab"
}

resource "libvirt_volume" "ubuntu2204" {
    name = "ubuntu2204.qcow2"
    pool = "mklab"
    format = "qcow2"
    source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    depends_on = [libvirt_pool.mklab]
}

resource "libvirt_volume" "mklabnode1" {
    name = "mklabnode1.qcow2"
    pool = "mklab"
    format = "qcow2"
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_cloudinit_disk" "mklabnode1" {
    name = "mklabnode1.iso"
    user_data = file("${path.module}/mklabnode1_user_data")
    network_config = file("${path.module}/mklabnode1_network_config")
}

resource "libvirt_domain" "mklabnode1" {
    name = "mklabnode1"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.mklabnode1.id
    }
    network_interface {
        network_id = libvirt_network.mklab.id
    }
    cloudinit = libvirt_cloudinit_disk.mklabnode1.id
    depends_on = [libvirt_volume.mklabnode1, libvirt_network.mklab]
}
