#!/bin/bash

export NUM_LAYERS=12
export HIDDEN_SIZE=1536
export FFN_HIDDEN_SIZE=8208
export MOE_FFN_HIDDEN_SIZE=1056
export MOE_LAYER_FREQ="[0]*1+[1]*11"
export MICRO_BATCH_SIZE=8
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=8815
export SAVE_INTERVAL=880
export EVAL_INTERVAL=880
sbatch --job-name=flame-moe-721m --nodes=4 scripts/training/flame-moe.sh
