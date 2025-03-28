#!/bin/bash
# Set up the runtime environment.

export DATASET_PREFIX=MoE-Research/dataset
export WEIGHTS_PREFIX=MoE-Research/weights

export DATASET_DIR=/mnt/localssd/$DATASET_PREFIX
export WEIGHTS_DIR=/mnt/localssd/$WEIGHTS_PREFIX
mkdir -p $DATASET_DIR $WEIGHTS_DIR

export BUCKET=gs://cmu-gpucloud-haok
export GCP_DATASET_DIR=$BUCKET/$DATASET_PREFIX
export GCP_WEIGHTS_DIR=$BUCKET/$WEIGHTS_PREFIX

export NFS_MOUNT=$PWD/slurm-$SLURM_JOB_ID
export SSD_MOUNT=/mnt/localssd/slurm-$SLURM_JOB_ID
mkdir -p $NFS_MOUNT $SSD_MOUNT

source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
