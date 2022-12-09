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

resource "libvirt_network" "deplab_external" {
    name = "deplab_external"
    mode = "nat"
    addresses = ["192.168.249.0/24"]
    dns {
        enabled = false
    }
    dhcp {
        enabled = false
    }
}

resource "libvirt_network" "deplab_internal" {
    name = "deplab_internal"
    mode = "none"
    addresses = ["192.168.248.0/24"]
    dns {
        enabled = false
    }
    dhcp {
        enabled = false
    }
}

resource "libvirt_pool" "deplab" {
    name = "deplab"
    type = "dir"
    path = "/mnt/libvirt/deplab"
}

resource "libvirt_volume" "ubuntu2204" {
    name = "ubuntu2204.qcow2"
    pool = "deplab"
    format = "qcow2"
    source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    depends_on = [libvirt_pool.deplab]
}

resource "libvirt_volume" "deplabserver" {
    name = "deplabserver.qcow2"
    pool = "deplab"
    format = "qcow2"
    size = 32 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_cloudinit_disk" "deplabserver" {
    name = "deplabserver.iso"
    user_data = file("${path.module}/deplabserver_user_data")
    network_config = file("${path.module}/deplabserver_network_data")
}

resource "libvirt_domain" "deplabserver" {
    name = "deplabserver"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.deplabserver.id
    }
    network_interface {
        network_id = libvirt_network.deplab_external.id
    }
    network_interface {
        network_id = libvirt_network.deplab_internal.id
    }
    cloudinit = libvirt_cloudinit_disk.deplabserver.id
    depends_on = [libvirt_volume.deplabserver, libvirt_network.deplab_external, libvirt_network.deplab_internal]
}
