#!/bin/bash

export NUM_LAYERS=48
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=10944
export MOE_FFN_HIDDEN_SIZE=1408
export MOE_LAYER_FREQ="[0]*1+[1]*47"
export MICRO_BATCH_SIZE=8
export PIPELINE_MODEL_PARALLEL_SIZE=4
export EXPERT_MODEL_PARALLEL_SIZE=64
export TRAIN_ITERS=17337
export SAVE_INTERVAL=1000
export EVAL_INTERVAL=1000
sbatch --job-name=flame-moe-4.3b --nodes=8 scripts/training/flame-moe.sh
