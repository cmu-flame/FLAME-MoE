#!/bin/bash

export NUM_LAYERS=12
export HIDDEN_SIZE=512
export FFN_HIDDEN_SIZE=2736
export MOE_FFN_HIDDEN_SIZE=352
export MOE_LAYER_FREQ="[0]*1+[1]*11"
export MICRO_BATCH_SIZE=16
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=4165
export SAVE_INTERVAL=416
export EVAL_INTERVAL=416
sbatch --job-name=flame-moe-115m --nodes=4 scripts/training/flame-moe.sh
