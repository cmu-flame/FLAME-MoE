#!/bin/bash
# Sync files from GCP to local filesystem
# Author: Hao Kang | Date: April 5, 2025

# Only run on the first local task
if [ "$SLURM_LOCALID" -eq 0 ]; then
    gcloud storage rsync --recursive "$GCP_DATASET_PATH" "$DATASET_PATH"
    gcloud storage rsync --recursive "$GCP_WEIGHTS_PATH" "$WEIGHTS_PATH"
fi
