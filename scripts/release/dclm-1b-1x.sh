#!/bin/bash

export NUM_LAYERS=24
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=5632
export NUM_ATTENTION_HEADS=16
export MICRO_BATCH_SIZE=4
export TRAIN_ITERS=13252
export SAVE_INTERVAL=1320
export EVAL_INTERVAL=1320
sbatch --job-name=dclm-1b-1x --nodes=4 scripts/training/dclm.sh
