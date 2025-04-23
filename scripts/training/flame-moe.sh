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

export MODEL_SCALE="${MODEL_SCALE:-410m}"

export TRAIN_DATASET="${TRAIN_DATASET:-$GCP_DATASET/dclm-138b/tokenized/EleutherAI/pythia-12b}"
export TRAIN_WEIGHTS="${TRAIN_WEIGHTS:-$GCP_WEIGHTS/flame-moe-$PARAM_SCALE/$SLURM_JOB_ID}"

export NUM_EXPERTS="${NUM_EXPERTS:-32}"
export MOE_ROUTER_TOPK="${MOE_ROUTER_TOPK:-16}"

export PARAM_RDZV_BACKEND="c10d"
export PARAM_RDZV_ENDPOINT="${PARAM_RDZV_ENDPOINT:-$(hostname):8000}"
export PIPELINE_MODEL_PARALLEL_SIZE=8

export MICRO_BATCH_SIZE=2
export TRAIN_ITERS=100

srun -W 0 scripts/training/modules/flame-moe_step1.sh
srun -W 0 scripts/training/modules/flame-moe_step2.sh
srun -W 0 scripts/training/modules/flame-moe_step3.sh
