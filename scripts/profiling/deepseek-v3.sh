#!/bin/bash

#SBATCH --job-name=deepseek-v3
#SBATCH --output=logs/%x/%j/stdout.log

#SBATCH --partition=flame
#SBATCH --time=00-01:00:00
#SBATCH --qos=flame-t1b_g1_qos

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=1024G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:8

# Check if required environment variables are set.
if [ -z "$DATASET" ]; then
  echo "Error: DATASET is not set"
  exit 1
fi

if [ -z "$TOKENIZER" ]; then
  echo "Error: TOKENIZER is not set"
  exit 1
fi

# Setup the runtime environment.
source devconfig.sh
source devsecret.sh

# Ensure cleanup of temporary directories on exit.
trap 'rm -rf $NFS_MOUNT $SSD_MOUNT' EXIT

# Setup directories for dataset and profile.
export DATASET_PATH=$DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export PROFILE_PATH=$PROFILE_DIR/$SLURM_JOB_NAME/$SLURM_JOB_ID/
export GCP_DATASET_PATH=$GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export GCP_PROFILE_PATH=$GCP_PROFILE_DIR/$SLURM_JOB_NAME/$SLURM_JOB_ID/
mkdir -p $DATASET_PATH $PROFILE_PATH

# Mark the first node as the master.
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Download the dataset and profile.
srun -W 0 scripts/profiling/modules/download.sh

# Dispatch the training.
srun -W 0 scripts/profiling/modules/deepseek-v3_step1.sh
