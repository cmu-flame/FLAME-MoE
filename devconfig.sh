#!/bin/bash
# Set up the runtime environment.
# Usage: source devconfig.sh

# Author: Hao Kang
# Date: March 27, 2025

# Specify the directories.
# NFS_SPACE is mounted across all nodes.
# SSD_SPACE is local to each node but with faster I/O.
export NFS_SPACE=$PWD/slurm-$SLURM_JOB_ID
export SSD_SPACE=/mnt/localssd/slurm-$SLURM_JOB_ID
mkdir -p $NFS_SPACE $SSD_SPACE
export DATASET_SSD=$SSD_SPACE/dataset
export WEIGHTS_SSD=$SSD_SPACE/weights
mkdir -p $DATASET_SSD $WEIGHTS_SSD

# Specify the shared directories inside the bucket.
# All team members should have read access to dataset and weights.
export TEAM_BUCKET=cmu-gpucloud-haok
export DATASET_GCP=MoE-Research/dataset
export WEIGHTS_GCP=MoE-Research/weights

# Activate the environment.
source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
