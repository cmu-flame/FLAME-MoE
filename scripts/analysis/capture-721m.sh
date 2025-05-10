#!/bin/bash

source scripts/config.sh

export NUM_LAYERS=12
export HIDDEN_SIZE=1536
export FFN_HIDDEN_SIZE=8208
export MOE_FFN_HIDDEN_SIZE=1056
export MOE_LAYER_FREQ="[0]*1+[1]*11"
export MICRO_BATCH_SIZE=8
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=8815
export RDZV_BACKEND="c10d"
export RDZV_ENDPOINT="localhost:8000"

export TRAIN_JOB_ID=31067
export TRAIN_JOB_NAME=flame-moe-721m
export TRAIN_WEIGHTS=$GCP_WEIGHTS/$TRAIN_JOB_NAME/$TRAIN_JOB_ID
export TRAIN_DATASET=$GCP_DATASET/dclm-138b/tokenized/EleutherAI/pythia-12b

bash scripts/analysis/modules/capture_step1.sh

for item in $SSD_WEIGHTS/iter_*; do
    name=$(basename $item)
    step=$((10#${name#iter_}))
    export EACT_SAVE=$SSD_MOUNT/actives/$step
    export TIDS_SAVE=$SSD_MOUNT/samples
    echo $step > $SSD_WEIGHTS/latest_checkpointed_iteration.txt
    echo "Capturing $step ..."
    bash scripts/analysis/modules/capture_step2.sh
done

bash scripts/analysis/modules/capture_step3.sh
