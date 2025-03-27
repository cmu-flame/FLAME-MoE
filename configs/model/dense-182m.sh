#!/bin/bash
#  Definition for the dense-182m model.

# This script is adapted from the following sources:
# - https://github.com/thu-ml/ReMoE/blob/main/scripts/train_llama_182m_dense.sh
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md
# For a comprehensive list of all available arguments, refer to:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

MODEL_ARGS=(
    # Model Architecture & General Configuration
    --num-layers 12
    --hidden-size 768
    --ffn-hidden-size 3072
    --num-attention-heads 12
    --untie-embeddings-and-output-weights

    # Sequence & Positional Embeddings
    --seq-length 1024
    --max-position-embeddings 1024
    --position-embedding-type rope
    --no-position-embedding

    # Attention Mechanism & Variants
    --use-flash-attn
    --no-masked-softmax-fusion

    # Dropout & Normalization
    --attention-dropout 0.0
    --hidden-dropout 0.0
    --normalization LayerNorm

    # Miscellaneous
    --disable-bias-linear
)
