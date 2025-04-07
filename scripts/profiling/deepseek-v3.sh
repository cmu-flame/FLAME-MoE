#!/bin/bash

#SBATCH --job-name=profile-deepseek-v3
#SBATCH --output=logs/%x/%j.log

#SBATCH --partition=flame
#SBATCH --time=00-01:00:00
#SBATCH --qos=flame-t1b_g1_qos

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=1024G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:8

# Setup the runtime environment.
source devconfig.sh
source devsecret.sh

# Ensure cleanup of temporary directories on exit.
trap 'rm -rf $NFS_MOUNT $SSD_MOUNT' EXIT

# Setup directories for dataset and weights.
export DATASET_PATH=$DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export WEIGHTS_PATH=$WEIGHTS_DIR/deepseek-v2-lite/$SLURM_JOB_ID/
export GCP_DATASET_PATH=$GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export GCP_WEIGHTS_PATH=$GCP_WEIGHTS_DIR/deepseek-v2-lite/$SLURM_JOB_ID/
mkdir -p $DATASET_PATH $WEIGHTS_PATH

# Mark the first node as the master.
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Download the dataset and weights.
srun -W 0 scripts/profiling/modules/download.sh

# Dispatch the training.
srun -W 0 scripts/profiling/modules/deepseek-v3_step1.sh
