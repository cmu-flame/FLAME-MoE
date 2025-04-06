#!/bin/bash
# Infrastructure configuration for dense-1.4b training
# Author: Hao Kang | Date: April 5, 2025

# Based on:
# - https://huggingface.co/EleutherAI/pythia-1.4b/blob/main/config.json
# - https://arxiv.org/pdf/2304.01373
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md
#
# For full argument details, see:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

# Torch distributed launch config
TORCH_ARGS=(
    --nnodes "$SLURM_NNODES"
    --node_rank "$SLURM_NODEID"
    --nproc_per_node "$SLURM_GPUS_ON_NODE"
    --rdzv-id "$SLURM_JOB_ID"
    --rdzv-backend c10d
    --rdzv-endpoint "$MASTER_ADDR:$MASTER_PORT"
)

# Megatron-LM infrastructure args
INFRA_ARGS=(
    --tensor-model-parallel-size 1
    --pipeline-model-parallel-size 1
    --sequence-parallel
    --use-distributed-optimizer
    --overlap-grad-reduce
    --overlap-param-gather
)
