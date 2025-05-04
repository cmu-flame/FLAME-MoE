#!/bin/bash

export NUM_LAYERS=24
export HIDDEN_SIZE=2062
export FFN_HIDDEN_SIZE=11019
export MOE_FFN_HIDDEN_SIZE=1418
export MOE_LAYER_FREQ="[0]*1+[1]*23"
export MICRO_BATCH_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=32480
export WANDB_RUN_GROUP=release
sbatch --nodes=4 scripts/training/flame-moe.sh
