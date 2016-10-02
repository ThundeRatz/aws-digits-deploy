#!/bin/bash
sudo nvidia-docker run --name digits -d -p 5000:34448 -v /ebs/jobs:/jobs -v /ebs/data:/data/ebs-data nvidia/digits
