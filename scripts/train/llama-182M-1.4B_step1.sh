#!/bin/bash
# Invoked by scripts/train/llama-182M-1.4B.sh
# Adopted from the following:
# - https://github.com/thu-ml/ReMoE/blob/main/scripts/train_llama_182m_moe.sh
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md

# Author: Zichun Yu
# Date: March 10, 2025

export CUDA_DEVICE_MAX_CONNECTIONS=1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

PROJECT_NAME=$SLURM_JOB_NAME.$SLURM_JOB_ID
WEIGHTS_PATH=$WEIGHTS_DIR/$PROJECT_NAME

source configs/model/llama-182M-1.4B.sh
source configs/infra/llama-182M-1.4B.sh
source configs/logging.sh

DATA_PATH=$(find $DATASET_DIR/dclm-28B-gpt2bpe/ -type f -name *.bin |
    xargs -I {} sh -c "echo -n \"$DATASET_DIR/dclm-28B-gpt2bpe/\$(basename {} .bin) \"" |
    sed 's/ $//')

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model openai-community/gpt2
    --data-path $DATA_PATH
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 16
    --global-batch-size 512
    --lr 5e-4
    --train-iters 60000
    --lr-decay-style cosine
    --min-lr 5e-5
    --lr-warmup-fraction 0.01
    --clip-grad 1.0
    --bf16
)

cd Megatron-LM && torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
    ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} ${LOG_ARGS[@]} ${DATA_ARGS[@]} ${TRAIN_ARGS[@]}
