#!/bin/bash
# FLAME MoE 410M Train Config.
# 410M refers to active parameters when 1 expert is active under granularity of 1.

# This script is adapted from the following sources:
# https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md

TORCH_ARGS=(
    --nnodes $SLURM_NNODES
    --node_rank $SLURM_NODEID
    --nproc_per_node $SLURM_GPUS_ON_NODE
    --rdzv-id $SLURM_JOB_ID
    --rdzv-backend $RDZV_BACKEND
    --rdzv-endpoint $RDZV_ENDPOINT
)

INFRA_ARGS=(
    --sequence-parallel
    --tensor-model-parallel-size 1
    --pipeline-model-parallel-size $PIPELINE_MODEL_PARALLEL_SIZE
    --expert-model-parallel-size 1
    --use-distributed-optimizer
    --overlap-grad-reduce
    --overlap-param-gather
    --moe-token-dispatcher-type alltoall
    --bf16
)

TRAIN_ARGS=(
    --micro-batch-size $MICRO_BATCH_SIZE
    --global-batch-size 1024
    --lr 3e-4
    --min-lr 3e-5
    --lr-decay-style WSD
    --lr-warmup-fraction 0.01
    --lr-wsd-decay-iters $((TRAIN_ITERS / 10))
    --train-iters $TRAIN_ITERS
)
