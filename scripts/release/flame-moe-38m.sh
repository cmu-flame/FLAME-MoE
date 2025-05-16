#!/bin/bash

export NUM_LAYERS=9
export HIDDEN_SIZE=256
export FFN_HIDDEN_SIZE=1368
export MOE_FFN_HIDDEN_SIZE=176
export MOE_LAYER_FREQ="[0]*1+[1]*8"
export MICRO_BATCH_SIZE=32
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=2121
export SAVE_INTERVAL=212
export EVAL_INTERVAL=212
sbatch --job-name=flame-moe-38m --nodes=4 scripts/training/flame-moe.sh
