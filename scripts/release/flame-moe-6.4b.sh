#!/bin/bash

export NUM_LAYERS=33
export HIDDEN_SIZE=3008
export FFN_HIDDEN_SIZE=16074
export MOE_FFN_HIDDEN_SIZE=2068
export MOE_LAYER_FREQ="[0]*1+[1]*32"
export MICRO_BATCH_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=70780
export WANDB_RUN_GROUP=release
sbatch --nodes=8 scripts/training/flame-moe.sh
