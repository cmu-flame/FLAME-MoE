#!/bin/bash
# This script is adapted from the following sources:
# - https://huggingface.co/allenai/OLMoE-1B-7B-0924/blob/main/config.json
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md
# For a comprehensive list of all available arguments, refer to:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

TORCH_ARGS=(
    --nnodes $SLURM_NNODES
    --node_rank $SLURM_NODEID
    --nproc_per_node $SLURM_GPUS_ON_NODE
    --rdzv-id $SLURM_JOB_ID
    --rdzv-backend c10d
    --rdzv-endpoint $MASTER_ADDR:$MASTER_PORT
)

INFRA_ARGS=(
    --tensor-model-parallel-size 1
    --pipeline-model-parallel-size 4
    --expert-model-parallel-size 8
    --sequence-parallel
    --use-distributed-optimizer
    --overlap-grad-reduce
    --overlap-param-gather
)
