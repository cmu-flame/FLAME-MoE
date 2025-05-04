#!/bin/bash

export NUM_LAYERS=42
export HIDDEN_SIZE=4096
export FFN_HIDDEN_SIZE=21888
export MOE_FFN_HIDDEN_SIZE=2816
export MOE_LAYER_FREQ="[0]*1+[1]*41"
export MICRO_BATCH_SIZE=1
export PIPELINE_MODEL_PARALLEL_SIZE=8
export EXPERT_MODEL_PARALLEL_SIZE=32
export TRAIN_ITERS=500
sbatch --job-name=flame-moe-14.8b --nodes=8 scripts/training/flame-moe.sh
