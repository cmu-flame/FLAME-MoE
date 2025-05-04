#!/bin/bash

# Remove leftover directories from previous jobs
find /mnt/localssd -mindepth 1 -maxdepth 1 -type d -user $USER \
    ! -name docker ! -name job_tmp ! -name lost+found ! -exec rm -rvf {} \;

# Download training dataset (retry until success)
mkdir -p $SSD_DATASET
echo "[$(hostname)] Fetching $TRAIN_DATASET ..."
until gcloud storage cp --quiet --recursive $TRAIN_DATASET/ $SSD_DATASET/; do continue; done
echo "[$(hostname)] Done."
