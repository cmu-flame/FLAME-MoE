#!/bin/bash

#SBATCH --job-name=evaluate
#SBATCH --output=logs/evaluate-%j.log
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=32
#SBATCH --mem=256G
#SBATCH --time=2-00:00:00

source scripts/config.sh
source scripts/secret.sh

trap "rm -rf $NFS_MOUNT $SSD_MOUNT" EXIT

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
export HF_DATASETS_TRUST_REMOTE_CODE=true

source configs/model/flame-moe.sh
gcloud storage cp -r $GCP_WEIGHTS/flame-moe/$JOBID/* $SSD_WEIGHTS/
# echo $ITERS > $SSD_WEIGHTS/latest_checkpointed_iteration.txt

cd lm-evaluation-harness && PYTHONPATH=$PWD/../Megatron-LM accelerate launch -m lm_eval \
    ${MODEL_ARGS[@]} \
    --bf16 \
    --seq-length 2048 \
    --micro-batch-size 4 \
    --batch_size 16 \
    --max-tokens-to-oom 10000000 \
    --seed 42 \
    --load $SSD_WEIGHTS \
    --model megatron_lm \
    --tasks "arc_easy,arc_challenge,boolq,hellaswag,winogrande,piqa,race,lambada_openai" \
    --output_path ../logs/results/flame-moe/$JOBID