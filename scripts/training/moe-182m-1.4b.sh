#!/bin/bash
# Train moe-182m-1.4b model.

# Author: Hao Kang
# Date: March 21, 2025

#SBATCH --job-name=moe-182m-1.4b
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --mem=256G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:2

source devconfig.sh
source devsecret.sh
trap 'rm -rf $NFS_MOUNT $SSD_MOUNT' EXIT

export DATASET_PATH=$DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export WEIGHTS_PATH=$WEIGHTS_DIR/moe-182m-1.4b/$JID/
mkdir -p $DATASET_PATH $WEIGHTS_PATH

export GCP_DATASET_PATH=$GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export GCP_WEIGHTS_PATH=$GCP_WEIGHTS_DIR/moe-182m-1.4b/$JID/

export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

srun -W 0 scripts/training/modules/moe-182m-1.4b_step1.sh
