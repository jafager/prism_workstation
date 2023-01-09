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

variable "cp_count" {
    type = number
    description = "The number of control plane nodes to create."
    default = 3
}

variable "wk_count" {
    type = number
    description = "The number of worker nodes to create."
    default = 3
}

variable "lb_count" {
    type = number
    description = "The number of load balancers to create."
    default = 1
}

variable "stor_count" {
    type = number
    description = "The number of storage nodes to create."
    default = 1
}

resource "libvirt_network" "simplab_management" {
    name = "simplab_management"
    mode = "nat"
    addresses = ["192.168.247.0/24"]
    autostart = true
    dns {
        enabled = false
    }
    dhcp {
        enabled = false
    }
}

resource "libvirt_network" "simplab_metallb" {
    name = "simplab_metallb"
    mode = "none"
    addresses = ["192.168.246.0/24"]
    autostart = true
    dns {
        enabled = false
    }
    dhcp {
        enabled = false
    }
}

resource "libvirt_pool" "simplab" {
    name = "simplab"
    type = "dir"
    path = "/mnt/libvirt/simplab"
}

resource "libvirt_volume" "ubuntu2204" {
    name = "ubuntu2204.qcow2"
    pool = "simplab"
    format = "qcow2"
    source = "/home/jafager/projects/prism_workstation/jammy-server-cloudimg-amd64.img"
    depends_on = [libvirt_pool.simplab]
}

resource "libvirt_volume" "simplabcp" {
    count = var.cp_count
    name = "simplabcp${count.index + 1}.qcow2"
    pool = "simplab"
    format = "qcow2"
    size = 32 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "simplabwk" {
    count = var.wk_count
    name = "simplabwk${count.index + 1}.qcow2"
    pool = "simplab"
    format = "qcow2"
    size = 32 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "simplablb" {
    count = var.lb_count
    name = "simplablb${count.index + 1}.qcow2"
    pool = "simplab"
    format = "qcow2"
    size = 16 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "simplabstor" {
    count = var.stor_count
    name = "simplabstor${count.index + 1}.qcow2"
    pool = "simplab"
    format = "qcow2"
    size = 128 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_cloudinit_disk" "simplabcp" {
    count = var.cp_count
    name = "simplabcp${count.index + 1}.iso"
    user_data = templatefile("${path.module}/simplabcp_user_data.tftpl", { hostname = "simplabcp${count.index + 1}", fqdn = "simplabcp${count.index + 1}.simplab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9My5YdUN2wC+FC90bSCF6t3jrMGESv7+eafQETfD3t1bCwoPHpXywzeP6qVfgCxQQa7mmBT5sEOrJjtVw02QQA8C7vca+rprMOrN6rooCAZDlt8whoARv++MjgMnBset2QxuL5OoTOkLmVdw0rTubbxqf80CjZL/T7DVD04sS9CEQQOY7Qb9IzPtykATvKzalWLqT7GJNx+oMghGbAjx/AO4KyEwFgAEeT6vd72AtwsS7PKv46dL44IQSEg1T3Z6HVW0sF0/w9VMcujgwvBuveLGoRuH2kiniWiYSBOylbuTu1SMnKMHsJHm11aMqhnhZCB9fZPOdjYBuUZOMa0hiWq3WXq11Q+UMJurcQTFlB1bZf9ZBPwJzERiw4Z1eZwBC5JucAtajQYpsjRKskCKdixpkJ5l9oinKwfjYCnj+SjE+GeT7on3QA8iCtR4WCixdFVYszkfOX1SPd3mzRdohIjgAg3rWxOP/jkEXUm289F/uKAQUg5bIzIEJNAIfNWU= jafager@prism" })
    network_config = templatefile("${path.module}/simplabcp_network_config.tftpl", { ip_addresses_1 = "[192.168.247.${10 + (count.index + 1)}/24]", gateway = "192.168.247.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[simplab.prism.local]", ip_addresses_2 = "[192.168.246.${10 + (count.index + 1)}/24]" })
}

resource "libvirt_cloudinit_disk" "simplabwk" {
    count = var.wk_count
    name = "simplabwk${count.index + 1}.iso"
    user_data = templatefile("${path.module}/simplabwk_user_data.tftpl", { hostname = "simplabwk${count.index + 1}", fqdn = "simplabwk${count.index + 1}.simplab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9My5YdUN2wC+FC90bSCF6t3jrMGESv7+eafQETfD3t1bCwoPHpXywzeP6qVfgCxQQa7mmBT5sEOrJjtVw02QQA8C7vca+rprMOrN6rooCAZDlt8whoARv++MjgMnBset2QxuL5OoTOkLmVdw0rTubbxqf80CjZL/T7DVD04sS9CEQQOY7Qb9IzPtykATvKzalWLqT7GJNx+oMghGbAjx/AO4KyEwFgAEeT6vd72AtwsS7PKv46dL44IQSEg1T3Z6HVW0sF0/w9VMcujgwvBuveLGoRuH2kiniWiYSBOylbuTu1SMnKMHsJHm11aMqhnhZCB9fZPOdjYBuUZOMa0hiWq3WXq11Q+UMJurcQTFlB1bZf9ZBPwJzERiw4Z1eZwBC5JucAtajQYpsjRKskCKdixpkJ5l9oinKwfjYCnj+SjE+GeT7on3QA8iCtR4WCixdFVYszkfOX1SPd3mzRdohIjgAg3rWxOP/jkEXUm289F/uKAQUg5bIzIEJNAIfNWU= jafager@prism" })
    network_config = templatefile("${path.module}/simplabwk_network_config.tftpl", { ip_addresses_1 = "[192.168.247.${20 + (count.index + 1)}/24]", gateway = "192.168.247.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[simplab.prism.local]", ip_addresses_2 = "[192.168.246.${20 + (count.index + 1)}/24]" })
}

resource "libvirt_cloudinit_disk" "simplablb" {
    count = var.lb_count
    name = "simplablb${count.index + 1}.iso"
    user_data = templatefile("${path.module}/simplablb_user_data.tftpl", { hostname = "simplablb${count.index + 1}", fqdn = "simplablb${count.index + 1}.simplab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9My5YdUN2wC+FC90bSCF6t3jrMGESv7+eafQETfD3t1bCwoPHpXywzeP6qVfgCxQQa7mmBT5sEOrJjtVw02QQA8C7vca+rprMOrN6rooCAZDlt8whoARv++MjgMnBset2QxuL5OoTOkLmVdw0rTubbxqf80CjZL/T7DVD04sS9CEQQOY7Qb9IzPtykATvKzalWLqT7GJNx+oMghGbAjx/AO4KyEwFgAEeT6vd72AtwsS7PKv46dL44IQSEg1T3Z6HVW0sF0/w9VMcujgwvBuveLGoRuH2kiniWiYSBOylbuTu1SMnKMHsJHm11aMqhnhZCB9fZPOdjYBuUZOMa0hiWq3WXq11Q+UMJurcQTFlB1bZf9ZBPwJzERiw4Z1eZwBC5JucAtajQYpsjRKskCKdixpkJ5l9oinKwfjYCnj+SjE+GeT7on3QA8iCtR4WCixdFVYszkfOX1SPd3mzRdohIjgAg3rWxOP/jkEXUm289F/uKAQUg5bIzIEJNAIfNWU= jafager@prism" })
    network_config = templatefile("${path.module}/simplablb_network_config.tftpl", { ip_addresses_1 = "[192.168.247.${30 + (count.index + 1)}/24]", gateway = "192.168.247.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[simplab.prism.local]" })
}

resource "libvirt_cloudinit_disk" "simplabstor" {
    count = var.stor_count
    name = "simplabstor${count.index + 1}.iso"
    user_data = templatefile("${path.module}/simplabstor_user_data.tftpl", { hostname = "simplabstor${count.index + 1}", fqdn = "simplabstor${count.index + 1}.simplab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9My5YdUN2wC+FC90bSCF6t3jrMGESv7+eafQETfD3t1bCwoPHpXywzeP6qVfgCxQQa7mmBT5sEOrJjtVw02QQA8C7vca+rprMOrN6rooCAZDlt8whoARv++MjgMnBset2QxuL5OoTOkLmVdw0rTubbxqf80CjZL/T7DVD04sS9CEQQOY7Qb9IzPtykATvKzalWLqT7GJNx+oMghGbAjx/AO4KyEwFgAEeT6vd72AtwsS7PKv46dL44IQSEg1T3Z6HVW0sF0/w9VMcujgwvBuveLGoRuH2kiniWiYSBOylbuTu1SMnKMHsJHm11aMqhnhZCB9fZPOdjYBuUZOMa0hiWq3WXq11Q+UMJurcQTFlB1bZf9ZBPwJzERiw4Z1eZwBC5JucAtajQYpsjRKskCKdixpkJ5l9oinKwfjYCnj+SjE+GeT7on3QA8iCtR4WCixdFVYszkfOX1SPd3mzRdohIjgAg3rWxOP/jkEXUm289F/uKAQUg5bIzIEJNAIfNWU= jafager@prism" })
    network_config = templatefile("${path.module}/simplabstor_network_config.tftpl", { ip_addresses_1 = "[192.168.247.${40 + (count.index + 1)}/24]", gateway = "192.168.247.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[simplab.prism.local]" })
}

resource "libvirt_domain" "simplabcp" {
    count = var.cp_count
    name = "simplabcp${count.index + 1}"
    vcpu = "2"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.simplabcp[count.index].id
    }
    network_interface {
        network_id = libvirt_network.simplab_management.id
    }
    network_interface {
        network_id = libvirt_network.simplab_metallb.id
    }
    cloudinit = libvirt_cloudinit_disk.simplabcp[count.index].id
    depends_on = [libvirt_volume.simplabcp, libvirt_network.simplab_management, libvirt_network.simplab_metallb]
}

resource "libvirt_domain" "simplabwk" {
    count = var.wk_count
    name = "simplabwk${count.index + 1}"
    vcpu = "2"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.simplabwk[count.index].id
    }
    network_interface {
        network_id = libvirt_network.simplab_management.id
    }
    network_interface {
        network_id = libvirt_network.simplab_metallb.id
    }
    cloudinit = libvirt_cloudinit_disk.simplabwk[count.index].id
    depends_on = [libvirt_volume.simplabwk, libvirt_network.simplab_management, libvirt_network.simplab_metallb]
}

resource "libvirt_domain" "simplablb" {
    count = var.lb_count
    name = "simplablb${count.index + 1}"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.simplablb[count.index].id
    }
    network_interface {
        network_id = libvirt_network.simplab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.simplablb[count.index].id
    depends_on = [libvirt_volume.simplablb, libvirt_network.simplab_management]
}

resource "libvirt_domain" "simplabstor" {
    count = var.stor_count
    name = "simplabstor${count.index + 1}"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.simplabstor[count.index].id
    }
    network_interface {
        network_id = libvirt_network.simplab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.simplabstor[count.index].id
    depends_on = [libvirt_volume.simplabstor, libvirt_network.simplab_management]
}
