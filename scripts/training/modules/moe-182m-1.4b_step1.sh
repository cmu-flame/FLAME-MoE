#!/bin/bash
# Invoked by scripts/training/moe-182m-1.4b.sh

# Author: Hao Kang
# Date: March 21, 2025

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

source configs/model/moe-182m-1.4b.sh
source configs/infra/moe-182m-1.4b.sh

if [ $SLURM_LOCALID -eq 0 ]; then
    gcloud storage rsync --recursive --delete-unmatched-destination-objects $GCP_DATASET_PATH $DATASET_PATH
    gcloud storage rsync --recursive --delete-unmatched-destination-objects $GCP_WEIGHTS_PATH $WEIGHTS_PATH
fi

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model $TOKENIZER
    --data-path $(find $DATASET_PATH -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 64
    --global-batch-size 512
    --lr 5e-4
    --min-lr 5e-5
    --lr-decay-style cosine
    --lr-warmup-fraction 0.01
    --train-iters 60000
    --clip-grad 1.0
    --bf16
)

LOG_ARGS=(
    --log-interval 10
    --log-throughput
    --save $WEIGHTS_PATH
    --save-interval 10000
    --load $WEIGHTS_PATH
    --eval-interval 1000
    --eval-iters 100
    --wandb-save-dir $SSD_MOUNT
    --wandb-project "MoE-Research"
    --wandb-exp-name $SLURM_JOB_NAME.$JID
    --tensorboard-dir $WEIGHTS_PATH
)

cd Megatron-LM
torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
    ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} \
    ${DATA_ARGS[@]} ${TRAIN_ARGS[@]} ${LOG_ARGS[@]} &

TORCHRUN_PID=$!
if [ $SLURM_LOCALID -eq 0 ]; then
    (
        while kill -0 $TORCHRUN_PID 2>/dev/null; do
            gcloud storage rsync --recursive $WEIGHTS_PATH $GCP_WEIGHTS_PATH
            sleep 10m
        done
    ) &
fi

wait $TORCHRUN_PID
if [ $SLURM_LOCALID -eq 0 ]; then
    gcloud storage rsync --recursive $WEIGHTS_PATH $GCP_WEIGHTS_PATH
fi
