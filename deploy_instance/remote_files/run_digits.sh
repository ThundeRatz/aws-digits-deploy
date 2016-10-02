#!/bin/bash
RUN_ARGS="-e DIGITS_JOBS_DIR=/jobs --name digits -d -p 5000:34448 -v /ebs/jobs:/jobs -v /ebs/data:/data/ebs-data nvidia/digits"
# Docker fails launching at creation; see https://github.com/docker/docker/issues/4036
sudo nvidia-docker run --rm $RUN_ARGS || sudo nvidia-docker run --rm $RUN_ARGS
