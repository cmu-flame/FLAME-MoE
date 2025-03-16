#!/bin/bash
# This script is adapted from the following sources:
# - https://github.com/thu-ml/ReMoE/blob/main/scripts/train_llama_182m_moe.sh
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
    --rotary-base 1000000

    # Attention Mechanism & Variants
    --group-query-attention
    --num-query-groups 4
    --use-flash-attn
    --no-masked-softmax-fusion

    # Dropout & Normalization
    --attention-dropout 0.0
    --hidden-dropout 0.0
    --normalization RMSNorm

    # Initialization & Activation Functions
    --init-method-std 0.01
    --swiglu

    # Mixture of Experts (MoE) Configuration
    --num-experts 8
    --moe-router-topk 1
    --moe-router-load-balancing-type aux_loss
    --moe-aux-loss-coeff 1e-2
    --moe-token-dispatcher-type alltoall
    --moe-router-pre-softmax
    --moe-grouped-gemm

    # Miscellaneous
    --disable-bias-linear
)
