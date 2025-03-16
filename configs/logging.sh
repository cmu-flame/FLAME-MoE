#!/bin/bash
# For a comprehensive list of all available arguments, refer to:
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/training/arguments.py

LOG_ARGS=(
    --log-interval 10
    --log-throughput
    --save $WEIGHTS_PATH
    --save-interval 10000
    --load $WEIGHTS_PATH
    --eval-interval 1000
    --eval-iters 100
    --wandb-save-dir $WEIGHTS_PATH/wandb
    --wandb-project "MoE-Research"
    --wandb-exp-name $PROJECT_NAME
)
