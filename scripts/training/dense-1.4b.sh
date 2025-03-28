#!/bin/bash
# Train dense-1.4b model.
# Usage: scripts/train/dense-1.4b.sh

# Author: Hao Kang
# Date: March 21, 2025

#SBATCH --job-name=dense-1.4b
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=128G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1

source devconfig.sh
source devsecret.sh

export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000
export DATASET_PATH_SSD=$DATASET_SSD/$DATASET/tokenized/$TOKENIZER/
export DATASET_PATH_GCP=$DATASET_GCP/$DATASET/tokenized/$TOKENIZER/
export WEIGHTS_PATH_SSD=$WEIGHTS_SSD/dense-1.4b/$SLURM_JOB_ID/
export WEIGHTS_PATH_GCP=$WEIGHTS_GCP/dense-1.4b/$SLURM_JOB_ID/

# Dispatch the tasks to the nodes.
srun -W 0 scripts/training/modules/dense-1.4b_step1.sh
