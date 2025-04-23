#!/bin/bash

export GCP_MOUNT="gs://cmu-gpucloud-haok/flame-moe"
export SSD_MOUNT="/mnt/localssd/slurm-$SLURM_JOB_ID"

export SSD_QUEUE="$SSD_MOUNT/queue"
mkdir -p $SSD_QUEUE

export GCP_DATASET="$GCP_MOUNT/dataset"
export SSD_DATASET="$SSD_MOUNT/dataset"
mkdir -p $SSD_DATASET

export GCP_WEIGHTS="$GCP_MOUNT/weights"
export SSD_WEIGHTS="$SSD_MOUNT/weights"
mkdir -p $SSD_WEIGHTS
