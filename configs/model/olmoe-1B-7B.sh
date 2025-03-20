#!/bin/bash
# This script is adapted from the following sources:
# - https://huggingface.co/allenai/OLMoE-1B-7B-0924/blob/main/config.json
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md
# For a comprehensive list of all available arguments, refer to:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

MODEL_ARGS=(
    # Model Architecture & General Configuration
    --num-layers 16
    --hidden-size 2048
    --ffn-hidden-size 1024
    --num-attention-heads 16
    --untie-embeddings-and-output-weights

    # Sequence & Positional Embeddings
    --seq-length 4096
    --max-position-embeddings 4096
    --position-embedding-type rope
    --no-position-embedding

    # Attention Mechanism & Variants
    --group-query-attention
    --num-query-groups 8
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
    --num-experts 64
    --moe-router-topk 8
    --moe-router-load-balancing-type aux_loss
    --moe-aux-loss-coeff 1e-2
    --moe-token-dispatcher-type alltoall
    --moe-router-pre-softmax
    --moe-grouped-gemm

    # Miscellaneous
    --disable-bias-linear
)
