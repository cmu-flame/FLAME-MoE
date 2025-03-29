#!/bin/bash
# Infrastructure for training the deepseek-v2-lite model.

# This script is adapted from the following sources:
# - https://huggingface.co/deepseek-ai/DeepSeek-V2-Lite/blob/main/config.json
# - https://github.com/alibaba/Pai-Megatron-Patch/blob/main/examples/deepseek_v2/run_mcore_deepseek.sh
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
    --decoder-first-pipeline-num-layers 6
    --expert-model-parallel-size 2
    --sequence-parallel
    --use-distributed-optimizer
    --overlap-grad-reduce
    --overlap-param-gather
)
