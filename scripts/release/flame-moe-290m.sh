#!/bin/bash

export NUM_LAYERS=9
export HIDDEN_SIZE=1024
export FFN_HIDDEN_SIZE=5472
export MOE_FFN_HIDDEN_SIZE=704
export MOE_LAYER_FREQ="[0]*1+[1]*8"
export MICRO_BATCH_SIZE=8
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=5473
export SAVE_INTERVAL=540
export EVAL_INTERVAL=540
sbatch --job-name=flame-moe-290m --nodes=4 scripts/training/flame-moe.sh
