#!/bin/bash
# Train dense-182m model
# Author: Hao Kang | Date: March 21, 2025

#SBATCH --job-name=dense-182m
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --mem=256G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:2

# Load environment config and secrets
source devconfig.sh
source devsecret.sh

# Clean up job directories on exit
trap 'rm -rf $NFS_MOUNT $SSD_MOUNT' EXIT

# Set dataset and weight paths
export DATASET_PATH=$DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export WEIGHTS_PATH=$WEIGHTS_DIR/dense-182m/$SLURM_JOB_ID/
mkdir -p "$DATASET_PATH" "$WEIGHTS_PATH"

export GCP_DATASET_PATH=$GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export GCP_WEIGHTS_PATH=$GCP_WEIGHTS_DIR/dense-182m/$SLURM_JOB_ID/

# Set distributed training master address
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Sync existing data and previous weights
srun -W 0 scripts/training/modules/remote_to_local.sh

# Launch training step
srun -W 0 scripts/training/modules/dense-182m_step1.sh
