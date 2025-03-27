#!/bin/bash
# Invoked by scripts/training/dense-182m.sh

# Author: Hao Kang
# Date: March 27, 2025

if [ $SLURM_LOCALID -eq 0 ]; then
    echo "$(hostname) - Copying dataset from GCP bucket to local disk space"
    gcloud storage rsync --recursive $GCPBUCKET/$DATASET_PATH $DISKSPACE/$DATASET_PATH
fi
