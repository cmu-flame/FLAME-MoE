#!/bin/bash

export NUM_LAYERS=48
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=10944
export MOE_FFN_HIDDEN_SIZE=1408
export MOE_LAYER_FREQ="[0]*1+[1]*47"
export MICRO_BATCH_SIZE=1
export PIPELINE_MODEL_PARALLEL_SIZE=4
export EXPERT_MODEL_PARALLEL_SIZE=16
export TRAIN_ITERS=17337
sbatch --job-name=flame-moe-4.3b --nodes=8 scripts/training/flame-moe.sh
