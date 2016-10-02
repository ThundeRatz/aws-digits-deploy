#!/bin/bash
set -ex
cd "$(dirname "$0")"
. metadata.sh
. utils.sh

# Enable byobu forever
echo _byobu_sourced=1 . /usr/bin/byobu-launch >> ~/.profile

# CUDA
download_and_install_deb "$CUDA_REPO"
apt_install cuda
echo /usr/local/cuda-$CUDA_VERSION/lib64 | sudo tee /etc/ld.so.conf.d/cuda.conf
sudo ldconfig
echo "PATH=/usr/local/cuda-$CUDA_VERSION/bin:$PATH" | sudo tee -a /etc/profile
. /etc/profile

# Docker
apt_install docker-engine
systemctl enable docker.service

# NVIDIA-docker
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.0-rc.3/nvidia-docker_1.0.0.rc.3-1_amd64.deb
sudo dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
systemctl enable nvidia-docker.service

# EBS setup (1)
sudo mkfs -t ext4 /dev/sdb1

# fstab
sudo mkdir /ebs
UUID=$(file /dev/disk/by-uuid/* | grep sdb1 | sed 's|/dev/disk/by-uuid/\([^:]*\).*|\1|')
echo "UUID=$UUID    /ebs    ext4    defaults,nofail    0    2" | sudo tee -a /etc/fstab
sudo mount -a

# EBS setup (2)
sudo mkdir /ebs/data /ebs/jobs

./run_digits.sh
