<?php

  $hostname  = isset($_GET['hostname'])  ? $_GET['hostname']  : 'localhost';
  $ipaddress = isset($_GET['ipaddress']) ? $_GET['ipaddress'] : '127.0.0.1';
  $maskbits  = isset($_GET['maskbits'])  ? $_GET['maskbits']  : '8';
  $data      = isset($_GET['data'])      ? $_GET['data']      : 'unspecified';

  if ($data == 'vendor-data')
  {
    print("# no vendor data\n");
    exit();
  }
  elseif ($data == 'meta-data')
  {
    print("# no meta data\n");
    exit();
  }
  elseif ($data == 'user-data')
  {
    // Don't exit, so the rest of the content gets emitted
  }
  else
  {
    print("# invalid request\n");
    exit();
  }

?>
#cloud-config
autoinstall:
  apt:
    disable_components: []
    geoip: true
    preserve_sources_list: false
    primary:
    - arches:
      - amd64
      - i386
      uri: http://us.archive.ubuntu.com/ubuntu
    - arches:
      - default
      uri: http://ports.ubuntu.com/ubuntu-ports
  drivers:
    install: false
  identity:
    hostname: <?php printf("%s\n", $hostname); ?>
    password: $6$36cwdjJBC71W2L1G$FKwol67dwqPQwC2zeLsEZc3EWyUgU0zC7s4AncLM9cz20f4hbXK0sdE97IYbxhbVe5GH0LvIhVxZWcNt8kzE41
    realname: Jason A. Fager
    username: jafager
  kernel:
    package: linux-generic
  keyboard:
    layout: us
    toggle: null
    variant: ''
  locale: en_US.UTF-8
  network:
    ethernets:
      ens3:
        addresses:
        - <?php printf("%s/%s\n", $ipaddress, $maskbits); ?>
        gateway4: 192.168.248.11
        nameservers:
          addresses:
          - 8.8.8.8
          - 8.8.4.4
    version: 2
  source:
    id: synthesized
    search_drivers: false
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: true
  storage:
    config:
    - ptable: gpt
      path: /dev/vda
      wipe: superblock-recursive
      preserve: false
      name: ''
      grub_device: true
      type: disk
      id: disk-vda
    - device: disk-vda
      size: 1048576
      flag: bios_grub
      number: 1
      preserve: false
      grub_device: false
      offset: 1048576
      type: partition
      id: partition-0
    - device: disk-vda
      size: 1073741824
      wipe: superblock
      number: 2
      preserve: false
      grub_device: false
      offset: 2097152
      type: partition
      id: partition-1
    - fstype: ext4
      volume: partition-1
      preserve: false
      type: format
      id: format-0
    - device: disk-vda
      size: -1
      wipe: superblock
      number: 3
      preserve: false
      grub_device: false
      offset: 1075838976
      type: partition
      id: partition-2
    - name: rootvg
      devices:
      - partition-2
      preserve: false
      type: lvm_volgroup
      id: lvm_volgroup-0
    - name: swap
      volgroup: lvm_volgroup-0
      size: 2147483648B
      wipe: superblock
      preserve: false
      type: lvm_partition
      id: lvm_partition-0
    - fstype: swap
      volume: lvm_partition-0
      preserve: false
      type: format
      id: format-1
    - path: ''
      device: format-1
      type: mount
      id: mount-1
    - name: root
      volgroup: lvm_volgroup-0
      size: 17179869184B
      wipe: superblock
      preserve: false
      type: lvm_partition
      id: lvm_partition-1
    - fstype: ext4
      volume: lvm_partition-1
      preserve: false
      type: format
      id: format-2
    - path: /
      device: format-2
      type: mount
      id: mount-2
    - path: /boot
      device: format-0
      type: mount
      id: mount-0
    swap:
      swap: 0
  updates: security
  timezone: America/New_York
  shutdown: reboot
  version: 1
