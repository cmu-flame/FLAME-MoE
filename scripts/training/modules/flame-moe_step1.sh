#!/bin/bash

# Remove leftover directories from previous jobs
docker run --rm -it -v /mnt/localssd:/mnt/localssd ubuntu bash -c "find /mnt/localssd -mindepth 1 -maxdepth 1 ! -name docker ! -name job_tmp -exec rm -rvf {} +"

# Download training dataset (retry until success)
echo "[$(hostname)] Fetching $TRAIN_DATASET ..."
mkdir -p $SSD_DATASET
until gcloud storage cp --quiet --recursive $TRAIN_DATASET/ $SSD_DATASET/; do continue; done
echo "[$(hostname)] Done."
