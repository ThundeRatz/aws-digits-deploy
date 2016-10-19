#!/bin/bash
set -e
if (( $# != 1 )) ; then
    echo "Usage: deploy.sh target_address"
    exit 1
fi

cd "$(dirname "$0")"

remote="ubuntu@$1"
scp -r remote_files/ "$remote":
ssh "$remote" remote_files/aws_setup.sh
