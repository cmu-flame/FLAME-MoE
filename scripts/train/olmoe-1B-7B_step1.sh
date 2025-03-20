#!/bin/bash
# Invoked by scripts/train/olmoe-1B-7B.sh
# Adopted from the following:
# - https://huggingface.co/allenai/OLMoE-1B-7B-0924/blob/main/config.json
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md

# Author: Hao Kang
# Date: March 9, 2025

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

PROJECT_NAME=$SLURM_JOB_NAME.$SLURM_JOB_ID
DATASET_PATH=$DATASET_DIR/dclm-28B-olmoe
WEIGHTS_PATH=$WEIGHTS_DIR/$PROJECT_NAME

source configs/model/olmoe-1B-7B.sh
source configs/infra/olmoe-1B-7B.sh
source configs/logging.sh

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model allenai/OLMoE-1B-7B-0924
    --data-path $(find $DATASET_PATH -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 1
    --global-batch-size 128
    --lr 1e-4
    --min-lr 1.0e-5
    --lr-decay-style cosine
    --lr-warmup-iters 60
    --lr-decay-iters 38400
    --weight-decay 0.1
    --train-iters 60000
    --clip-grad 1.0
    --bf16
)

cd Megatron-LM && torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
    ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} ${LOG_ARGS[@]} ${DATA_ARGS[@]} ${TRAIN_ARGS[@]}
