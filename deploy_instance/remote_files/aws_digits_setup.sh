#!/bin/bash
set -ex
cd "$(dirname "$0")"
. metadata.sh
. utils.sh

# Enable byobu forever
echo _byobu_sourced=1 . /usr/bin/byobu-launch >> ~/.profile

# Linux headers
sudo apt-get update
sudo apt-get install -y "linux-headers-$(uname -r)" || echo \
    "Installation of kernel for $(uname -r) failed.\n" \
    "This is an expected failure if running inside a container." \

# CUDA
download_and_install_deb "$CUDA_REPO"
# Might fail the first time when handling cyclic deps
sudo apt-get install -y cuda || sudo apt-get install -y cuda
echo /usr/local/cuda-$CUDA_VERSION/lib64 | sudo tee /etc/ld.so.conf.d/cuda.conf
sudo ldconfig
echo "PATH=/usr/local/cuda-$CUDA_VERSION/bin:$PATH" | sudo tee -a /etc/profile
. /etc/profile

# cuDNN
sudo dpkg -i libcudnn5*+cuda*_amd64.deb

# DIGITS
download_and_install_deb "$NVIDIA_MACHINE_LEARNING_REPO"
sudo apt-get install -y digits
