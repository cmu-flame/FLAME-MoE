#!/bin/bash
# Infrastructure setup with FLAME MoE.

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
    --expert-model-parallel-size $EXPERT_MODEL_PARALLEL_SIZE
    --use-distributed-optimizer
    --overlap-grad-reduce
    --overlap-param-gather
    --moe-token-dispatcher-type alltoall
    --distributed-timeout-minutes 30
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
