#!/bin/bash
# Download all files from the training dataset directory to local storage.
# Each file is downloaded individually with automatic retry until successful.

mkdir -p $SSD_DATASET

gcloud storage ls $TRAIN_DATASET/ | while read -r uri; do
    echo "[$(hostname)] Fetching $uri ..."
    until gcloud storage cp --no-user-output-enabled $uri $SSD_DATASET/; do continue; done
done
