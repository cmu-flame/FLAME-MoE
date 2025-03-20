#!/bin/bash
# Invoked by scripts/train/llama-182M-1.4B.sh
# This script is adapted from the following sources:
# - https://github.com/thu-ml/ReMoE/blob/main/scripts/train_llama_182m_moe.sh
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md
# For a comprehensive list of all available arguments, refer to:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

# Author: Zichun Yu
# Date: March 10, 2025

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

PROJECT_NAME=$SLURM_JOB_NAME.$SLURM_JOB_ID
DATASET_PATH=$DATASET_DIR/dclm-28B-gpt2bpe
WEIGHTS_PATH=$WEIGHTS_DIR/$PROJECT_NAME

source configs/model/llama-182M-1.4B.sh
source configs/infra/llama-182M-1.4B.sh
source configs/logging.sh

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model openai-community/gpt2
    --data-path $(find $DATASET_PATH -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 16
    --global-batch-size 512
    --lr 5e-4
    --min-lr 5e-5
    --lr-decay-style cosine
    --lr-warmup-fraction 0.01
    --train-iters 60000
    --clip-grad 1.0
    --bf16
)

cd Megatron-LM && torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
    ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} ${LOG_ARGS[@]} ${DATA_ARGS[@]} ${TRAIN_ARGS[@]}
