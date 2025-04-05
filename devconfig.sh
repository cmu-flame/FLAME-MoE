#!/bin/bash
# Setup runtime environment for Slurm job
# Author: Hao Kang | Date: April 5, 2025

# Dataset and weights paths
export DATASET_PREFIX=MoE-Research/dataset
export WEIGHTS_PREFIX=MoE-Research/weights

# Local SSD paths
export DATASET_DIR=/mnt/localssd/$DATASET_PREFIX
export WEIGHTS_DIR=/mnt/localssd/$WEIGHTS_PREFIX
mkdir -p $DATASET_DIR $WEIGHTS_DIR

# GCP bucket paths
export BUCKET=gs://cmu-gpucloud-haok
export GCP_DATASET_DIR=$BUCKET/$DATASET_PREFIX
export GCP_WEIGHTS_DIR=$BUCKET/$WEIGHTS_PREFIX

# Job-specific runtime directories
export NFS_MOUNT=$PWD/slurm-$SLURM_JOB_ID
export SSD_MOUNT=/mnt/localssd/slurm-$SLURM_JOB_ID
mkdir -p $NFS_MOUNT $SSD_MOUNT

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
