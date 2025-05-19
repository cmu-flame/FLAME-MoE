#!/bin/bash
# Capture the router traces for FLAME-MoE-290M-1.3B.

#SBATCH --job-name=capture-290m
#SBATCH --output=logs/%x/%j.log

#SBATCH --partition=flame
#SBATCH --time=14-00:00:00
#SBATCH --qos=flame-t1b_g1_qos

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

source scripts/config.sh

# model architecture for FLAME-MoE-290M-1.3B
export NUM_LAYERS=9
export HIDDEN_SIZE=1024
export FFN_HIDDEN_SIZE=5472
export MOE_FFN_HIDDEN_SIZE=704
export MOE_LAYER_FREQ="[0]*1+[1]*8"
export MICRO_BATCH_SIZE=8
export PIPELINE_MODEL_PARALLEL_SIZE=1
export EXPERT_MODEL_PARALLEL_SIZE=8
export TRAIN_ITERS=5473
export RDZV_BACKEND="c10d"
export RDZV_ENDPOINT="localhost:8000"

# where to load the pretrained weights and dataset
export TRAIN_JOB_ID=31066
export TRAIN_JOB_NAME=flame-moe-290m
export TRAIN_WEIGHTS=$GCP_WEIGHTS/$TRAIN_JOB_NAME/$TRAIN_JOB_ID
export TRAIN_DATASET=$GCP_DATASET/dclm-138b/tokenized/EleutherAI/pythia-12b

srun scripts/empirical_analysis/modules/capture_step1.sh

# trace the router for each iteration
for item in $(ls -d $SSD_WEIGHTS/iter_* | sort -r); do
    name=$(basename $item)
    step=$((10#${name#iter_}))
    echo "Capturing $step ..."
    export EACT_SAVE=$SSD_MOUNT/actives/$step
    export TIDS_SAVE=$SSD_MOUNT/samples
    echo $step > $SSD_WEIGHTS/latest_checkpointed_iteration.txt
    srun scripts/empirical_analysis/modules/capture_step2.sh
done

srun scripts/empirical_analysis/modules/capture_step3.sh
