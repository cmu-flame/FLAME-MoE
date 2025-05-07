#!/bin/bash

export NUM_LAYERS=18
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=10944
export MOE_FFN_HIDDEN_SIZE=1408
export MOE_LAYER_FREQ="[0]*1+[1]*17"
export MICRO_BATCH_SIZE=4
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=11029
export SAVE_INTERVAL=1100
export EVAL_INTERVAL=1100
sbatch --job-name=flame-moe-1.7b --nodes=4 scripts/training/flame-moe.sh
