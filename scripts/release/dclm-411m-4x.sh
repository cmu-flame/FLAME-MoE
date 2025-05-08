#!/bin/bash

export NUM_LAYERS=24
export HIDDEN_SIZE=1024
export FFN_HIDDEN_SIZE=2816
export NUM_ATTENTION_HEADS=8
export MICRO_BATCH_SIZE=8
export TRAIN_ITERS=15456
export SAVE_INTERVAL=1540
export EVAL_INTERVAL=1540
sbatch --job-name=dclm-411m-4x --nodes=2 scripts/training/dclm.sh
