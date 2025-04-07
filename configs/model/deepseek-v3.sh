#!/bin/bash
# Model configuration for DeepSeek V3 678B.

# This script is adapted for running DeepSeek-V3 with Megatron-LM.
# It follows the setup outlined in:
# - https://huggingface.co/deepseek-ai/DeepSeek-V3/blob/main/configuration_deepseek.py

# For a full list of training arguments and options, refer to:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

# The following features aren't yet ported into Megatron-LM:
# topk_method='noaux_tc'
# first_k_dense_replace=3
# rope_theta=10000.0

# Arguments in this script can be overridden via environment variables to simplify debugging.
# Default values are provided as fallbacks to use the official configuration.

MODEL_ARGS=(
    # Tokenizer
    --vocab-size 129280

    # Network Size
    --hidden-size 7168
    --ffn-hidden-size 18432
    --num-layers "${NUM_LAYERS:-61}"
    --num-attention-heads 128
    --swiglu
    --max-position-embeddings 4096
    --normalization RMSNorm
    --norm-epsilon 1e-6
    --untie-embeddings-and-output-weights
    --position-embedding-type rope
    --disable-bias-linear

    # Mixture of Experts
    --moe-ffn-hidden-size 2048
    --moe-shared-expert-intermediate-size $((1 * 2048)) # Using 1 shared expert with hidden size 2048
    --num-experts 256
    --moe-router-topk 8
    --moe-router-topk-scaling-factor 2.5
    --moe-router-num-groups 8
    --moe-router-group-topk 4
    --moe-layer-freq 1
    --moe-router-score-function sigmoid

    # Multi-head Latent Attention
    --kv-lora-rank 512
    --q-lora-rank 1536
    --qk-pos-emb-head-dim 64
    --v-head-dim 128
    --qk-head-dim 128

    # Regularization
    --hidden-dropout 0.0
    --attention-dropout 0.0

    # Initialization
    --init-method-std 0.02
)
