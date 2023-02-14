#!/bin/bash


# Upgrade packages
sudo apt update
sudo apt -y upgrade

# Install Ansible
sudo apt -y install software-properties-common
sudo apt-repository-add -y ppa:ansible/ansible
sudo apt update
sudo apt -y install ansible

# Install desktop environment
sudo apt -y install ubuntu-desktop-minimal

# Install Nvidia driver
sudo apt -y install nvidia-driver-525

# Install Chromium
sudo snap install chromium

# Install Visual Studio Code
sudo snap install --classic Code
