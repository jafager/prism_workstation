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

variable "node_count" {
    type = number
    description = "The number of nodes to create."
    default = 6
}

variable "lb_count" {
    type = number
    description = "The number of load balancers to create."
    default = 2
}

variable "stor_count" {
    type = number
    description = "The number of storage nodes to create."
    default = 1
}

resource "libvirt_network" "kadmlab_management" {
    name = "kadmlab_management"
    mode = "nat"
    domain = "kadmlab.prism.local"
    addresses = ["192.168.252.0/24"]
    autostart = true
    dns {
        enabled = true
        forwarders {
            address = "8.8.8.8"
        }
        forwarders {
            address = "8.8.4.4"
        }
        hosts {
            hostname = "kadmlabnode1"
            ip = "192.168.252.11"
        }
        hosts {
            hostname = "kadmlabnode2"
            ip = "192.168.252.12"
        }
        hosts {
            hostname = "kadmlabnode3"
            ip = "192.168.252.13"
        }
        hosts {
            hostname = "kadmlabnode4"
            ip = "192.168.252.14"
        }
        hosts {
            hostname = "kadmlabnode5"
            ip = "192.168.252.15"
        }
        hosts {
            hostname = "kadmlabnode6"
            ip = "192.168.252.16"
        }
        hosts {
            hostname = "kadmlablb1"
            ip = "192.168.252.21"
        }
        hosts {
            hostname = "kadmlablb2"
            ip = "192.168.252.22"
        }
        hosts {
            hostname = "kadmlabstor1"
            ip = "192.168.252.31"
        }
        hosts {
            hostname = "controlplane"
            ip = "192.168.252.100"
        }
    }
    dhcp {
        enabled = false
    }
}

resource "libvirt_network" "kadmlab_metallb" {
    name = "kadmlab_metallb"
    mode = "none"
    addresses = ["192.168.251.0/24"]
    autostart = true
    dns {
        enabled = false
    }
    dhcp {
        enabled = false
    }
}

resource "libvirt_pool" "kadmlab" {
    name = "kadmlab"
    type = "dir"
    path = "/mnt/libvirt/kadmlab"
}

resource "libvirt_volume" "ubuntu2204" {
    name = "ubuntu2204.qcow2"
    pool = "kadmlab"
    format = "qcow2"
    source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    depends_on = [libvirt_pool.kadmlab]
}

resource "libvirt_volume" "kadmlabnode" {
    count = var.node_count
    name = "kadmlabnode${count.index + 1}.qcow2"
    pool = "kadmlab"
    format = "qcow2"
    size = 32 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "kadmlablb" {
    count = var.lb_count
    name = "kadmlablb${count.index + 1}.qcow2"
    pool = "kadmlab"
    format = "qcow2"
    size = 16 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "kadmlabstor" {
    count = var.stor_count
    name = "kadmlabstor${count.index + 1}.qcow2"
    pool = "kadmlab"
    format = "qcow2"
    size = 128 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_cloudinit_disk" "kadmlabnode" {
    count = var.node_count
    name = "kadmlabnode${count.index + 1}.iso"
    user_data = templatefile("${path.module}/kadmlabnode_user_data.tftpl", { hostname = "kadmlabnode${count.index + 1}", fqdn = "kadmlabnode${count.index + 1}.kadmlab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9My5YdUN2wC+FC90bSCF6t3jrMGESv7+eafQETfD3t1bCwoPHpXywzeP6qVfgCxQQa7mmBT5sEOrJjtVw02QQA8C7vca+rprMOrN6rooCAZDlt8whoARv++MjgMnBset2QxuL5OoTOkLmVdw0rTubbxqf80CjZL/T7DVD04sS9CEQQOY7Qb9IzPtykATvKzalWLqT7GJNx+oMghGbAjx/AO4KyEwFgAEeT6vd72AtwsS7PKv46dL44IQSEg1T3Z6HVW0sF0/w9VMcujgwvBuveLGoRuH2kiniWiYSBOylbuTu1SMnKMHsJHm11aMqhnhZCB9fZPOdjYBuUZOMa0hiWq3WXq11Q+UMJurcQTFlB1bZf9ZBPwJzERiw4Z1eZwBC5JucAtajQYpsjRKskCKdixpkJ5l9oinKwfjYCnj+SjE+GeT7on3QA8iCtR4WCixdFVYszkfOX1SPd3mzRdohIjgAg3rWxOP/jkEXUm289F/uKAQUg5bIzIEJNAIfNWU= jafager@prism" })
    network_config = templatefile("${path.module}/kadmlabnode_network_config.tftpl", { ip_addresses_1 = "[192.168.252.${10 + (count.index + 1)}/24]", gateway = "192.168.252.1", nameservers = "[192.168.252.1]", domains = "[kadmlab.prism.local]", ip_addresses_2 = "[192.168.251.${10 + (count.index + 1)}/24]" })
}

resource "libvirt_cloudinit_disk" "kadmlablb" {
    count = var.lb_count
    name = "kadmlablb${count.index + 1}.iso"
    user_data = templatefile("${path.module}/kadmlablb_user_data.tftpl", { hostname = "kadmlablb${count.index + 1}", fqdn = "kadmlablb${count.index + 1}.kadmlab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9My5YdUN2wC+FC90bSCF6t3jrMGESv7+eafQETfD3t1bCwoPHpXywzeP6qVfgCxQQa7mmBT5sEOrJjtVw02QQA8C7vca+rprMOrN6rooCAZDlt8whoARv++MjgMnBset2QxuL5OoTOkLmVdw0rTubbxqf80CjZL/T7DVD04sS9CEQQOY7Qb9IzPtykATvKzalWLqT7GJNx+oMghGbAjx/AO4KyEwFgAEeT6vd72AtwsS7PKv46dL44IQSEg1T3Z6HVW0sF0/w9VMcujgwvBuveLGoRuH2kiniWiYSBOylbuTu1SMnKMHsJHm11aMqhnhZCB9fZPOdjYBuUZOMa0hiWq3WXq11Q+UMJurcQTFlB1bZf9ZBPwJzERiw4Z1eZwBC5JucAtajQYpsjRKskCKdixpkJ5l9oinKwfjYCnj+SjE+GeT7on3QA8iCtR4WCixdFVYszkfOX1SPd3mzRdohIjgAg3rWxOP/jkEXUm289F/uKAQUg5bIzIEJNAIfNWU= jafager@prism" })
    network_config = templatefile("${path.module}/kadmlablb_network_config.tftpl", { ip_addresses_1 = "[192.168.252.${20 + (count.index + 1)}/24]", gateway = "192.168.252.1", nameservers = "[192.168.252.1]", domains = "[kadmlab.prism.local]" })
}

resource "libvirt_cloudinit_disk" "kadmlabstor" {
    count = var.stor_count
    name = "kadmlabstor${count.index + 1}.iso"
    user_data = templatefile("${path.module}/kadmlabstor_user_data.tftpl", { hostname = "kadmlabstor${count.index + 1}", fqdn = "kadmlabstor${count.index + 1}.kadmlab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9My5YdUN2wC+FC90bSCF6t3jrMGESv7+eafQETfD3t1bCwoPHpXywzeP6qVfgCxQQa7mmBT5sEOrJjtVw02QQA8C7vca+rprMOrN6rooCAZDlt8whoARv++MjgMnBset2QxuL5OoTOkLmVdw0rTubbxqf80CjZL/T7DVD04sS9CEQQOY7Qb9IzPtykATvKzalWLqT7GJNx+oMghGbAjx/AO4KyEwFgAEeT6vd72AtwsS7PKv46dL44IQSEg1T3Z6HVW0sF0/w9VMcujgwvBuveLGoRuH2kiniWiYSBOylbuTu1SMnKMHsJHm11aMqhnhZCB9fZPOdjYBuUZOMa0hiWq3WXq11Q+UMJurcQTFlB1bZf9ZBPwJzERiw4Z1eZwBC5JucAtajQYpsjRKskCKdixpkJ5l9oinKwfjYCnj+SjE+GeT7on3QA8iCtR4WCixdFVYszkfOX1SPd3mzRdohIjgAg3rWxOP/jkEXUm289F/uKAQUg5bIzIEJNAIfNWU= jafager@prism" })
    network_config = templatefile("${path.module}/kadmlabstor_network_config.tftpl", { ip_addresses_1 = "[192.168.252.${30 + (count.index + 1)}/24]", gateway = "192.168.252.1", nameservers = "[192.168.252.1]", domains = "[kadmlab.prism.local]" })
}

resource "libvirt_domain" "kadmlabnode" {
    count = var.node_count
    name = "kadmlabnode${count.index + 1}"
    vcpu = "2"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.kadmlabnode[count.index].id
    }
    network_interface {
        network_id = libvirt_network.kadmlab_management.id
    }
    network_interface {
        network_id = libvirt_network.kadmlab_metallb.id
    }
    cloudinit = libvirt_cloudinit_disk.kadmlabnode[count.index].id
    depends_on = [libvirt_volume.kadmlabnode, libvirt_network.kadmlab_management, libvirt_network.kadmlab_metallb]
}

resource "libvirt_domain" "kadmlablb" {
    count = var.lb_count
    name = "kadmlablb${count.index + 1}"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.kadmlablb[count.index].id
    }
    network_interface {
        network_id = libvirt_network.kadmlab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.kadmlablb[count.index].id
    depends_on = [libvirt_volume.kadmlablb, libvirt_network.kadmlab_management]
}

resource "libvirt_domain" "kadmlabstor" {
    count = var.stor_count
    name = "kadmlabstor${count.index + 1}"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.kadmlabstor[count.index].id
    }
    network_interface {
        network_id = libvirt_network.kadmlab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.kadmlabstor[count.index].id
    depends_on = [libvirt_volume.kadmlabstor, libvirt_network.kadmlab_management]
}
