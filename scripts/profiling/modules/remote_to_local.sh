#!/bin/bash
# This script is used to synchronize files from Google Cloud Storage to the local filesystem.

if [ $SLURM_LOCALID -eq 0 ]; then
    gcloud storage rsync --recursive $GCP_DATASET_PATH $DATASET_PATH
    gcloud storage rsync --recursive $GCP_WEIGHTS_PATH $WEIGHTS_PATH
fi
