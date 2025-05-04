#!/bin/bash

export NUM_LAYERS=36
export HIDDEN_SIZE=3072
export FFN_HIDDEN_SIZE=16416
export MOE_FFN_HIDDEN_SIZE=2112
export MOE_LAYER_FREQ="[0]*1+[1]*35"
export MICRO_BATCH_SIZE=1
export PIPELINE_MODEL_PARALLEL_SIZE=4
export EXPERT_MODEL_PARALLEL_SIZE=16
export TRAIN_ITERS=500
export WANDB_RUN_GROUP=release
sbatch --job-name=flame-moe-7.2b --nodes=8 scripts/training/flame-moe.sh
