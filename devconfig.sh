#!/bin/bash
# Set up the runtime environment.
# Usage: source devconfig.sh

# Author: Hao Kang
# Date: March 27, 2025

# Specify the directories.
export BUCKET=cmu-gpucloud-haok
export GCP_MOUNT=/mnt/localssd/MoE-Research
export NFS_MOUNT=$PWD/slurm-$SLURM_JOB_ID
export SSD_MOUNT=/mnt/localssd/slurm-$SLURM_JOB_ID
mkdir -p $NFS_MOUNT $SSD_MOUNT $GCP_MOUNT

# Activate the environment.
source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
