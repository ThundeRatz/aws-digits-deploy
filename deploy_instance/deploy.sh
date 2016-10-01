#!/bin/bash
set -e
if (( $# != 1 )) ; then
    echo "Usage: deploy.sh target_address"
    exit 1
fi

. remote_files/metadata.sh

# Assert cuDNN is present
if ! ls remote_files/libcudnn5*+cuda"${CUDA_VERSION}"_amd64.deb ; then
    echo "Download cuDNN for CUDA ${CUDA_VERSION} and save to remote_files/"
    echo "cuDNN page: https://developer.nvidia.com/cudnn"
    exit 1
fi

remote="ubuntu@$1"
scp -r remote_files/ "$remote":
ssh "$remote" remote_files/aws_digits_setup.sh
