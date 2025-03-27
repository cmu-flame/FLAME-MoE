#!/bin/bash
# Invoked by scripts/training/dense-182m.sh

# Author: Hao Kang
# Date: March 21, 2025

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

TRAIN_ITERS=60000
PROJECT_NAME=$SLURM_JOB_NAME.$SLURM_JOB_ID
WEIGHTS_PATH=$WEIGHTS_PATH/$PROJECT_NAME

source configs/model/dense-182m.sh
source configs/infra/dense-182m.sh

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model $TOKENIZER
    --data-path $(find $DISKSPACE/$DATASET_PATH -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 64
    --global-batch-size 512
    --lr 5e-4
    --min-lr 5e-5
    --lr-decay-style cosine
    --lr-warmup-fraction 0.01
    --train-iters $TRAIN_ITERS
    --clip-grad 1.0
    --bf16
)

LOG_ARGS=(
    --log-interval 10
    --log-throughput
    --save $DISKSPACE/$WEIGHTS_PATH
    --save-interval 10000
    --load $DISKSPACE/$WEIGHTS_PATH
    --eval-interval 1000
    --eval-iters 100
    --wandb-save-dir /tmp/$PROJECT_NAME
    --wandb-project "MoE-Research"
    --wandb-exp-name $PROJECT_NAME
    --tensorboard-dir /tmp/$PROJECT_NAME
)

periodic_backup() {
    local src=$DISKSPACE/$WEIGHTS_PATH
    local dst=$GCPBUCKET/$WEIGHTS_PATH
    local idx=$src/latest_checkpointed_iteration.txt
    mkdir -p $src

    while true; do
        if [[ -f $idx ]]; then
            iter=$(cat $idx)
            if [[ $iter -ge $TRAIN_ITERS ]]; then
                echo "Final backup in progress..."
                gcloud storage rsync -r $src $dst
                break
            fi
        fi
        echo "Periodic backup in progress..."
        gcloud storage rsync -r $src $dst
        sleep 10m
    done
}

periodic_backup &

cd Megatron-LM && torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
    ${DATA_ARGS[@]} ${TRAIN_ARGS[@]} ${LOG_ARGS[@]} \
    ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} 

wait
