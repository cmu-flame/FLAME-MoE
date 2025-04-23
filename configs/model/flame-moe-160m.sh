#!/bin/bash
# FLAME MoE 160M Model Config.
# 160M refers to active parameters when 1 expert is active under granularity of 1.

# This script is adapted from the following sources:
# https://huggingface.co/EleutherAI/pythia-160m/blob/main/config.json

MODEL_ARGS=(
    # Network Size
    --hidden-size 768
    --ffn-hidden-size 3072
    --num-layers 12
    --num-attention-heads 12
    --swiglu
    --max-position-embeddings 2048
    --normalization RMSNorm
    --norm-epsilon 1e-6
    --untie-embeddings-and-output-weights
    --position-embedding-type rope
    --disable-bias-linear

    # Mixture of Experts
    --moe-ffn-hidden-size 3072
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
