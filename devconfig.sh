#!/bin/bash
# Setup runtime environment.

# Define the mounting point.
export DATASET_PREFIX=MoE-Research/dataset
export WEIGHTS_PREFIX=MoE-Research/weights
export PROFILE_PREFIX=MoE-Research/profile

# Local SSD paths
export DATASET_DIR=/mnt/localssd/$DATASET_PREFIX
export WEIGHTS_DIR=/mnt/localssd/$WEIGHTS_PREFIX
export PROFILE_DIR=/mnt/localssd/$PROFILE_PREFIX
mkdir -p $DATASET_DIR $WEIGHTS_DIR $PROFILE_DIR

# GCP bucket paths
export BUCKET=gs://cmu-gpucloud-haok
export GCP_DATASET_DIR=$BUCKET/$DATASET_PREFIX
export GCP_WEIGHTS_DIR=$BUCKET/$WEIGHTS_PREFIX
export GCP_PROFILE_DIR=$BUCKET/$PROFILE_PREFIX

# Job-specific runtime directories
export NFS_MOUNT=$PWD/slurm-$SLURM_JOB_ID
export SSD_MOUNT=/mnt/localssd/slurm-$SLURM_JOB_ID
mkdir -p $NFS_MOUNT $SSD_MOUNT

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
