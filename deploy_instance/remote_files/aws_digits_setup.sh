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
    "This is an expected failure if running inside a container."

# CUDA
apt_install() {
    sudo apt-get install -y --no-install-recommends "$@"
}
apt_install software-properties-common
sudo add-apt-repository universe  # freeglut3-dev is in universe as of 16.04
download_and_install_deb "$CUDA_REPO"
# Might fail the first time when handling cyclic deps
apt_install cuda || apt_install cuda
echo /usr/local/cuda-$CUDA_VERSION/lib64 | sudo tee /etc/ld.so.conf.d/cuda.conf
sudo ldconfig
echo "PATH=/usr/local/cuda-$CUDA_VERSION/bin:$PATH" | sudo tee -a /etc/profile
. /etc/profile

# cuDNN
sudo dpkg -i libcudnn5*+cuda${CUDA_VERSION}_amd64.deb

# caffe-nv
apt_install build-essential cmake git gfortran libatlas-base-dev libboost-all-dev \
    libgflags-dev libgoogle-glog-dev libhdf5-serial-dev libleveldb-dev liblmdb-dev \
    libopencv-dev libprotobuf-dev libsnappy-dev protobuf-compiler python-all-dev \
    python-dev python-h5py python-matplotlib python-numpy python-opencv python-pil \
    python-pip python-protobuf python-scipy python-setuptools python-skimage \
    python-sklearn
git clone --depth=1 https://github.com/NVIDIA/caffe.git ~/caffe
cd ~/caffe
sudo pip install -r python/requirements.txt
mkdir build
cd build
cmake ..
make -j4

# Torch
apt_install git software-properties-common libhdf5-serial-dev liblmdb-dev
git clone --depth=1 https://github.com/torch/distro.git ~/torch --recursive
cd ~/torch
./install-deps
./install.sh -b
source ~/.bashrc
luarocks install tds
luarocks install "https://raw.github.com/deepmind/torch-hdf5/master/hdf5-0-0.rockspec"
luarocks install lightningmdb 0.9.18.1-1 LMDB_INCDIR=/usr/include LMDB_LIBDIR=/usr/lib/x86_64-linux-gnu
luarocks install "https://raw.github.com/Sravan2j/lua-pb/master/lua-pb-scm-0.rockspec"
luarocks install "https://raw.githubusercontent.com/ngimel/nccl.torch/master/nccl-scm-1.rockspec"

# DIGITS
git clone --depth=1 https://github.com/NVIDIA/DIGITS.git ~/digits
cd ~/digits
sudo pip install -r requirements.txt
sudo pip install -e .
mkdir ~/jobs

# Systemd service
cat << EOF | sudo tee /etc/systemd/system/digits.service
[Unit]
Description=NVIDIA DIGITS server

[Service]
Type=simple
ExecStart=/home/ubuntu/digits/digits-devserver
Environment=DIGITS_JOBS_DIR=/home/ubuntu/jobs
Environment=CAFFE_ROOT=/home/ubuntu/caffe
Environment=TORCH_ROOT=/home/ubuntu/torch
EOF
