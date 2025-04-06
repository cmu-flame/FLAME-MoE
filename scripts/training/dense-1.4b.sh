#!/bin/bash
# Train dense-1.4b model
# Author: Hao Kang | Date: March 21, 2025

#SBATCH --job-name=dense-1.4b
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --mem=256G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:2

# Load configs and secrets
source devconfig.sh
source devsecret.sh

# Clean up job directories on exit
trap 'rm -rf $NFS_MOUNT $SSD_MOUNT' EXIT

# Set dataset and weights paths
export DATASET_PATH=$DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export WEIGHTS_PATH=$WEIGHTS_DIR/dense-1.4b/$SLURM_JOB_ID/
mkdir -p $DATASET_PATH $WEIGHTS_PATH

export GCP_DATASET_PATH=$GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export GCP_WEIGHTS_PATH=$GCP_WEIGHTS_DIR/dense-1.4b/$SLURM_JOB_ID/

# Set distributed training master address
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Sync existing dataset and previous weights from remote
srun -W 0 scripts/training/modules/remote_to_local.sh

# Start training
srun -W 0 scripts/training/modules/dense-1.4b_step1.sh
