#!/bin/bash

# Author: Zichun Yu
# Date: March 10, 2025

#SBATCH --job-name=evaluate
#SBATCH --output=logs/evaluate-%j.log
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=32
#SBATCH --mem=256G
#SBATCH --time=2-00:00:00

source devconfig.sh
source devsecret.env
trap "rm -rf $NFS_MOUNT $SSD_MOUNT" EXIT

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
export HF_DATASETS_TRUST_REMOTE_CODE=true

source configs/model/$MODEL.sh
gcloud storage cp -r $GCP_WEIGHTS_DIR/$MODEL/$JOBID/* $SSD_MOUNT/
echo $ITERS > $SSD_MOUNT/latest_checkpointed_iteration.txt

cd lm-evaluation-harness && PYTHONPATH=/home/$USER/MoE-Research/Megatron-LM torchrun \
    --nproc-per-node=1 --master_addr=localhost --master_port=6000 -m lm_eval \
    ${MODEL_ARGS[@]} \
    --bf16 \
    --micro-batch-size 1 \
    --max-tokens-to-oom 10000000 \
    --seed 42 \
    --load $SSD_MOUNT \
    --model megatron_lm \
    --tasks "arc_easy,arc_challenge,boolq,hellaswag,winogrande,piqa,race,lambada_openai" \
    --output_path /dev/null \
    --batch_size 16 \
    --tokenizer-type HuggingFaceTokenizer \
    --tokenizer-model $TOKENIZER
