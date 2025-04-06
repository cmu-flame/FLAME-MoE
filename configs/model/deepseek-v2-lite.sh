#!/bin/bash
# Model definition for the deepseek-v2-lite model.

# This script is adapted from the following sources:
# - https://huggingface.co/deepseek-ai/DeepSeek-V2-Lite/blob/main/config.json
# - https://github.com/alibaba/Pai-Megatron-Patch/blob/main/examples/deepseek_v2/README.md
# For a comprehensive list of all available arguments, refer to:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

MODEL_ARGS=(
    # Model Architecture & General Configuration
    --num-layers 27
    --hidden-size 2048
    --ffn-hidden-size 10944
    --num-attention-heads 16
    --untie-embeddings-and-output-weights
    --disable-bias-linear
    --swiglu
    --normalization RMSNorm

    # Sequence & Positional Embeddings
    --seq-length 1024
    --max-position-embeddings 1024
    --position-embedding-type rope
    --rotary-base 10000
    --rotary-scaling-factor 40

    # Attention Mechanism & Variants
    --use-flash-attn
    --no-bias-swiglu-fusion
    --no-rope-fusion
    --qk-layernorm

    # Dropout & Initialization
    --attention-dropout 0.0
    --hidden-dropout 0.0
    --init-method-std 0.008

    # Mixture of Experts (MoE) Configuration
    --num-experts 64
    --moe-ffn-hidden-size 1408
    --moe-router-topk 6
    --moe-router-load-balancing-type aux_loss
    --moe-aux-loss-coeff 1e-2
    --moe-shared-expert-intermediate-size 2816
)
