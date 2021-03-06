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
set +x ; . /etc/profile ; set -x

# Docker
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
apt_install docker-engine
echo 'DOCKER_OPTS="--storage-driver=overlay2"' | sudo tee /etc/default/docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

# NVIDIA-docker
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.0-rc.3/nvidia-docker_1.0.0.rc.3-1_amd64.deb
sudo dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
sudo systemctl enable nvidia-docker.service
sudo systemctl start nvidia-docker.service

# EBS setup (1)
sudo mkfs -t ext4 /dev/xvdb

# fstab
sudo mkdir /ebs
while [[ -z $UUID ]] ; do
    sleep 1
    echo Trying to read UUID of newly created filesystem
    UUID=$(file /dev/disk/by-uuid/* | grep ../../xvdb | sed 's|/dev/disk/by-uuid/\([^:]*\).*|\1|')
done
echo "UUID=$UUID    /ebs    ext4    defaults,nofail    0    2" | sudo tee -a /etc/fstab
sudo mount -a

# EBS setup (2)
sudo mkdir /ebs/data /ebs/jobs

./run_digits.sh
