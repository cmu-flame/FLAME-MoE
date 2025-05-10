#!/bin/bash

source scripts/config.sh

export NUM_LAYERS=18
export HIDDEN_SIZE=2048
export FFN_HIDDEN_SIZE=10944
export MOE_FFN_HIDDEN_SIZE=1408
export MOE_LAYER_FREQ="[0]*1+[1]*17"
export MICRO_BATCH_SIZE=4
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=11029
export RDZV_BACKEND="c10d"
export RDZV_ENDPOINT="localhost:8000"

export TRAIN_JOB_ID=31245
export TRAIN_JOB_NAME=flame-moe-1.7b
export TRAIN_WEIGHTS=$GCP_WEIGHTS/$TRAIN_JOB_NAME/$TRAIN_JOB_ID
export TRAIN_DATASET=$GCP_DATASET/dclm-138b/tokenized/EleutherAI/pythia-12b

bash scripts/analysis/modules/capture_step1.sh

for item in $(ls -d $SSD_WEIGHTS/iter_* | sort -r); do
    name=$(basename $item)
    step=$((10#${name#iter_}))
    export EACT_SAVE=$SSD_MOUNT/actives/$step
    export TIDS_SAVE=$SSD_MOUNT/samples
    echo $step > $SSD_WEIGHTS/latest_checkpointed_iteration.txt
    echo "Capturing $step ..."
    bash scripts/analysis/modules/capture_step2.sh
done

bash scripts/analysis/modules/capture_step3.sh
