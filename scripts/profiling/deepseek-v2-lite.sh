#!/bin/bash
# Profile the training for deepseek-v2-lite model.

#SBATCH --job-name=deepseek-v2-lite
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=512G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:8

source devconfig.sh
source devsecret.sh
trap 'rm -rf $NFS_MOUNT $SSD_MOUNT' EXIT

export DATASET_PATH=$DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export WEIGHTS_PATH=$WEIGHTS_DIR/deepseek-v2-lite/$SLURM_JOB_ID/
mkdir -p $DATASET_PATH $WEIGHTS_PATH

export GCP_DATASET_PATH=$GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/
export GCP_WEIGHTS_PATH=$GCP_WEIGHTS_DIR/deepseek-v2-lite/$SLURM_JOB_ID/

export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

srun -W 0 scripts/profiling/modules/remote_to_local.sh
srun -W 0 scripts/profiling/modules/deepseek-v2-lite_step1.sh
