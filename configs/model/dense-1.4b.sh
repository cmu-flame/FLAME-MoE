#!/bin/bash
# Model definition for dense-1.4b
# Author: Hao Kang | Date: April 5, 2025

# Based on:
# - https://huggingface.co/EleutherAI/pythia-1.4b/blob/main/config.json
# - https://arxiv.org/pdf/2304.01373
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md
#
# For full argument details, see:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

MODEL_ARGS=(
    # Architecture
    --num-layers 24
    --hidden-size 2048
    --ffn-hidden-size 8192
    --num-attention-heads 16
    --untie-embeddings-and-output-weights

    # Sequence & position
    --seq-length 1024
    --max-position-embeddings 1024
    --position-embedding-type rope
    --no-position-embedding

    # Attention
    --use-flash-attn
    --no-masked-softmax-fusion

    # Dropout & normalization
    --attention-dropout 0.0
    --hidden-dropout 0.0
    --normalization LayerNorm

    # Misc
    --disable-bias-linear
)
