#!/bin/bash

#SBATCH --job-name=flame-moe
#SBATCH --output=logs/%x/%j.log

#SBATCH --partition=flame
#SBATCH --time=14-00:00:00
#SBATCH --qos=flame-t1b_g1_qos

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

source scripts/config.sh
source scripts/secret.sh

export RDZV_BACKEND="c10d"
export RDZV_ENDPOINT="${RDZV_ENDPOINT:-$(hostname):8000}"
export TRAIN_WEIGHTS="${TRAIN_WEIGHTS:-$GCP_WEIGHTS/flame-moe/$SLURM_JOB_ID}"

srun -W 0 scripts/training/modules/flame-moe_step1.sh
srun -W 0 scripts/training/modules/flame-moe_step2.sh
srun -W 0 scripts/training/modules/flame-moe_step3.sh
