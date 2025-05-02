#!/bin/bash

# 2.5B Active Parameters
export NUM_LAYERS=27
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=10944
export MOE_FFN_HIDDEN_SIZE=1408
export MOE_LAYER_FREQ=[0]*1+[1]*26
export MICRO_BATCH_SIZE=2
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=7619
export WANDB_RUN_GROUP=testing-2.4e20
sbatch --nodes=8 scripts/training/flame-moe.sh

# 2.2B Active Parameters
export NUM_LAYERS=24
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=10944
export MOE_FFN_HIDDEN_SIZE=1408
export MOE_LAYER_FREQ=[0]*1+[1]*23
export MICRO_BATCH_SIZE=2
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=8495
export WANDB_RUN_GROUP=testing-2.4e20
sbatch --nodes=8 scripts/training/flame-moe.sh

# 1.7B Active Parameters
export NUM_LAYERS=18
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=10944
export MOE_FFN_HIDDEN_SIZE=1408
export MOE_LAYER_FREQ="[0]*1+[1]*17"
export MICRO_BATCH_SIZE=4
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=11029
export WANDB_RUN_GROUP=testing-2.4e20
sbatch --nodes=8 scripts/training/flame-moe.sh

# 1.0B Active Parameters
export NUM_LAYERS=18
export HIDDEN_SIZE=1536
export FFN_HIDDEN_SIZE=8208
export MOE_FFN_HIDDEN_SIZE=1056
export MOE_LAYER_FREQ="[0]*1+[1]*17"
export MICRO_BATCH_SIZE=4
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=18857
export WANDB_RUN_GROUP=testing-2.4e20
sbatch --nodes=8 scripts/training/flame-moe.sh
