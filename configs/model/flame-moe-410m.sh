#!/bin/bash
# FLAME MoE 410M Model Config.
# 410M refers to active parameters when 1 expert is active under granularity of 1.

# This script is adapted from the following sources:
# https://huggingface.co/EleutherAI/pythia-410m/blob/main/config.json

MODEL_ARGS=(
    # Network Size
    --hidden-size 1024
    --ffn-hidden-size 4096
    --num-layers 24
    --num-attention-heads 16
    --swiglu
    --max-position-embeddings 2048
    --normalization RMSNorm
    --norm-epsilon 1e-6
    --untie-embeddings-and-output-weights
    --position-embedding-type rope
    --disable-bias-linear

    # Mixture of Experts
    --moe-ffn-hidden-size 4096
    --num-experts $NUM_EXPERTS
    --moe-router-topk $MOE_ROUTER_TOPK
    --moe-router-pre-softmax
    --moe-router-score-function softmax
    --moe-aux-loss-coeff 0.01

    # Regularization
    --hidden-dropout 0.0
    --attention-dropout 0.0

    # Initialization
    --init-method-std 0.02

    # Tokenizer
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model EleutherAI/pythia-12b
)
