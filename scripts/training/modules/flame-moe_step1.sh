#!/bin/bash

# Delete leftover storage from my previous jobs
find /mnt/localssd -mindepth 1 -maxdepth 1 -type d -user $USER \
    ! -name docker ! -name job_tmp ! -name lost+found ! \
    -name "slurm-$SLURM_JOB_ID" -exec rm -rvf {} \;

# Download the training dataset (retry until successful)
mkdir -p $SSD_DATASET
until gcloud storage cp --recursive $TRAIN_DATASET/ $SSD_DATASET/; do continue; done
