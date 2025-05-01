#!/bin/bash

gcloud config set core/disable_file_logging True

export GCP_MOUNT="gs://cmu-gpucloud-haok/flame-moe"
export SSD_MOUNT="/mnt/localssd/slurm-$SLURM_JOB_ID"

export GCP_DATASET="$GCP_MOUNT/dataset"
export SSD_DATASET="$SSD_MOUNT/dataset"

export GCP_WEIGHTS="$GCP_MOUNT/weights"
export SSD_WEIGHTS="$SSD_MOUNT/weights"

source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
