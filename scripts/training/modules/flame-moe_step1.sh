#!/bin/bash
# Download all files from the training dataset directory to local storage.
# Each file is downloaded individually with automatic retry until successful.

mkdir -p $SSD_DATASET

gcloud storage ls $TRAIN_DATASET/ | xargs -P 16 -I {} bash -c '
    echo "[$(hostname)] Fetching {} ..."
    until gcloud storage cp --no-user-output-enabled {} '$SSD_DATASET/'; do continue; done
'
