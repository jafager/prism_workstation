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

resource "libvirt_network" "monlab_management" {
    name = "monlab_management"
    mode = "nat"
    addresses = ["192.168.245.0/24"]
    autostart = true
    dns {
        enabled = false
    }
    dhcp {
        enabled = false
    }
}

resource "libvirt_pool" "monlab" {
    name = "monlab"
    type = "dir"
    path = "/mnt/libvirt/monlab"
}

resource "libvirt_volume" "ubuntu2204" {
    name = "ubuntu2204.qcow2"
    pool = "monlab"
    format = "qcow2"
    source = "/home/jafager/projects/prism_workstation/jammy-server-cloudimg-amd64.img"
    depends_on = [libvirt_pool.monlab]
}

resource "libvirt_volume" "monlabcp" {
    count = var.cp_count
    name = "monlabcp${count.index + 1}.qcow2"
    pool = "monlab"
    format = "qcow2"
    size = 32 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "monlabwk" {
    count = var.wk_count
    name = "monlabwk${count.index + 1}.qcow2"
    pool = "monlab"
    format = "qcow2"
    size = 32 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "monlablb" {
    count = var.lb_count
    name = "monlablb${count.index + 1}.qcow2"
    pool = "monlab"
    format = "qcow2"
    size = 16 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "monlabstor" {
    count = var.stor_count
    name = "monlabstor${count.index + 1}.qcow2"
    pool = "monlab"
    format = "qcow2"
    size = 128 * 1024 * 1024 * 1024
    base_volume_name = "ubuntu2204.qcow2"
    depends_on = [libvirt_volume.ubuntu2204]
}

resource "libvirt_volume" "monlabstor_minio" {
    count = var.stor_count
    name = "monlabstor${count.index + 1}_minio.qcow2"
    pool = "monlab"
    format = "qcow2"
    size = 32 * 1024 * 1024 * 1024
    depends_on = [libvirt_pool.monlab]
}

resource "libvirt_cloudinit_disk" "monlabcp" {
    count = var.cp_count
    name = "monlabcp${count.index + 1}.iso"
    pool = "monlab"
    user_data = templatefile("${path.module}/monlabcp_user_data.tftpl", { hostname = "monlabcp${count.index + 1}", fqdn = "monlabcp${count.index + 1}.monlab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvwkuz9C+/yNORrC3zOr+XmefjnzB/Eue3NmiVGdYF66tCXyUuttvNLpzo7euBsgjP2fbY9HaV1bo1Vk9X7yqopN5LyKWfnbftK1o+cOKr8kWrro3SCLqmEWFuUgiU+vT8+slyRN1FH28JEOaxjdLGBSc9s/LxxagEq5pF6Sp6wvFPJ+Ur9IBXTIeAcVGJLC6eJW+H8OsstFTgG1xsoPMiDgIPK5UkpeXZZzebbNEFbOQDmncgOcG/y22YnG64tVCe9svzvetH49NtpFYIe45kNTZbXaa5P0kJXwjYwnHoIxE95yiWJec9Y3iawxy4mFn23HVh2dl3WFQziqhliaEAma0hZCnKCa/lNmu5RW94BCY31U1wdgMLa5tz9CdB9ymEq0EzxUdfQrbXST/pxYTsX/Gos6r75isNRj3DaiYdtVnTq3hJQxxyoJB9aZWGHwO/P+IKq3ZnfTyXo5uGUL1F6PoacSnd53r69hYCFIz8oZgzc8MtO5YEBR00uKN8g08= jafager@prism" })
    network_config = templatefile("${path.module}/monlabcp_network_config.tftpl", { ip_addresses_1 = "[192.168.245.${10 + (count.index + 1)}/24]", gateway = "192.168.245.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[monlab.prism.local]" })
}

resource "libvirt_cloudinit_disk" "monlabwk" {
    count = var.wk_count
    name = "monlabwk${count.index + 1}.iso"
    pool = "monlab"
    user_data = templatefile("${path.module}/monlabwk_user_data.tftpl", { hostname = "monlabwk${count.index + 1}", fqdn = "monlabwk${count.index + 1}.monlab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvwkuz9C+/yNORrC3zOr+XmefjnzB/Eue3NmiVGdYF66tCXyUuttvNLpzo7euBsgjP2fbY9HaV1bo1Vk9X7yqopN5LyKWfnbftK1o+cOKr8kWrro3SCLqmEWFuUgiU+vT8+slyRN1FH28JEOaxjdLGBSc9s/LxxagEq5pF6Sp6wvFPJ+Ur9IBXTIeAcVGJLC6eJW+H8OsstFTgG1xsoPMiDgIPK5UkpeXZZzebbNEFbOQDmncgOcG/y22YnG64tVCe9svzvetH49NtpFYIe45kNTZbXaa5P0kJXwjYwnHoIxE95yiWJec9Y3iawxy4mFn23HVh2dl3WFQziqhliaEAma0hZCnKCa/lNmu5RW94BCY31U1wdgMLa5tz9CdB9ymEq0EzxUdfQrbXST/pxYTsX/Gos6r75isNRj3DaiYdtVnTq3hJQxxyoJB9aZWGHwO/P+IKq3ZnfTyXo5uGUL1F6PoacSnd53r69hYCFIz8oZgzc8MtO5YEBR00uKN8g08= jafager@prism" })
    network_config = templatefile("${path.module}/monlabwk_network_config.tftpl", { ip_addresses_1 = "[192.168.245.${20 + (count.index + 1)}/24]", gateway = "192.168.245.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[monlab.prism.local]" })
}

resource "libvirt_cloudinit_disk" "monlablb" {
    count = var.lb_count
    name = "monlablb${count.index + 1}.iso"
    pool = "monlab"
    user_data = templatefile("${path.module}/monlablb_user_data.tftpl", { hostname = "monlablb${count.index + 1}", fqdn = "monlablb${count.index + 1}.monlab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvwkuz9C+/yNORrC3zOr+XmefjnzB/Eue3NmiVGdYF66tCXyUuttvNLpzo7euBsgjP2fbY9HaV1bo1Vk9X7yqopN5LyKWfnbftK1o+cOKr8kWrro3SCLqmEWFuUgiU+vT8+slyRN1FH28JEOaxjdLGBSc9s/LxxagEq5pF6Sp6wvFPJ+Ur9IBXTIeAcVGJLC6eJW+H8OsstFTgG1xsoPMiDgIPK5UkpeXZZzebbNEFbOQDmncgOcG/y22YnG64tVCe9svzvetH49NtpFYIe45kNTZbXaa5P0kJXwjYwnHoIxE95yiWJec9Y3iawxy4mFn23HVh2dl3WFQziqhliaEAma0hZCnKCa/lNmu5RW94BCY31U1wdgMLa5tz9CdB9ymEq0EzxUdfQrbXST/pxYTsX/Gos6r75isNRj3DaiYdtVnTq3hJQxxyoJB9aZWGHwO/P+IKq3ZnfTyXo5uGUL1F6PoacSnd53r69hYCFIz8oZgzc8MtO5YEBR00uKN8g08= jafager@prism" })
    network_config = templatefile("${path.module}/monlablb_network_config.tftpl", { ip_addresses_1 = "[192.168.245.${30 + (count.index + 1)}/24]", gateway = "192.168.245.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[monlab.prism.local]" })
}

resource "libvirt_cloudinit_disk" "monlabstor" {
    count = var.stor_count
    name = "monlabstor${count.index + 1}.iso"
    pool = "monlab"
    user_data = templatefile("${path.module}/monlabstor_user_data.tftpl", { hostname = "monlabstor${count.index + 1}", fqdn = "monlabstor${count.index + 1}.monlab.prism.local", username = "jafager", password = "Ubuntu22.04", ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvwkuz9C+/yNORrC3zOr+XmefjnzB/Eue3NmiVGdYF66tCXyUuttvNLpzo7euBsgjP2fbY9HaV1bo1Vk9X7yqopN5LyKWfnbftK1o+cOKr8kWrro3SCLqmEWFuUgiU+vT8+slyRN1FH28JEOaxjdLGBSc9s/LxxagEq5pF6Sp6wvFPJ+Ur9IBXTIeAcVGJLC6eJW+H8OsstFTgG1xsoPMiDgIPK5UkpeXZZzebbNEFbOQDmncgOcG/y22YnG64tVCe9svzvetH49NtpFYIe45kNTZbXaa5P0kJXwjYwnHoIxE95yiWJec9Y3iawxy4mFn23HVh2dl3WFQziqhliaEAma0hZCnKCa/lNmu5RW94BCY31U1wdgMLa5tz9CdB9ymEq0EzxUdfQrbXST/pxYTsX/Gos6r75isNRj3DaiYdtVnTq3hJQxxyoJB9aZWGHwO/P+IKq3ZnfTyXo5uGUL1F6PoacSnd53r69hYCFIz8oZgzc8MtO5YEBR00uKN8g08= jafager@prism" })
    network_config = templatefile("${path.module}/monlabstor_network_config.tftpl", { ip_addresses_1 = "[192.168.245.${40 + (count.index + 1)}/24]", gateway = "192.168.245.1", nameservers = "[8.8.8.8,8.8.4.4]", domains = "[monlab.prism.local]" })
}

resource "libvirt_domain" "monlabcp" {
    count = var.cp_count
    name = "monlabcp${count.index + 1}"
    vcpu = "2"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.monlabcp[count.index].id
    }
    network_interface {
        network_id = libvirt_network.monlab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.monlabcp[count.index].id
    depends_on = [libvirt_volume.monlabcp, libvirt_network.monlab_management]
}

resource "libvirt_domain" "monlabwk" {
    count = var.wk_count
    name = "monlabwk${count.index + 1}"
    vcpu = "2"
    memory = "8192"
    disk {
        volume_id = libvirt_volume.monlabwk[count.index].id
    }
    network_interface {
        network_id = libvirt_network.monlab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.monlabwk[count.index].id
    depends_on = [libvirt_volume.monlabwk, libvirt_network.monlab_management]
}

resource "libvirt_domain" "monlablb" {
    count = var.lb_count
    name = "monlablb${count.index + 1}"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.monlablb[count.index].id
    }
    network_interface {
        network_id = libvirt_network.monlab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.monlablb[count.index].id
    depends_on = [libvirt_volume.monlablb, libvirt_network.monlab_management]
}

resource "libvirt_domain" "monlabstor" {
    count = var.stor_count
    name = "monlabstor${count.index + 1}"
    vcpu = "1"
    memory = "4096"
    disk {
        volume_id = libvirt_volume.monlabstor[count.index].id
    }
    disk {
        volume_id = libvirt_volume.monlabstor_minio[count.index].id
    }
    network_interface {
        network_id = libvirt_network.monlab_management.id
    }
    cloudinit = libvirt_cloudinit_disk.monlabstor[count.index].id
    depends_on = [libvirt_volume.monlabstor, libvirt_volume.monlabstor_minio, libvirt_network.monlab_management]
}
