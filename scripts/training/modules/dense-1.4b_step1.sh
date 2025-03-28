#!/bin/bash
# Invoked by scripts/training/dense-1.4b.sh

# Author: Hao Kang
# Date: March 21, 2025

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

source configs/model/dense-1.4b.sh
source configs/infra/dense-1.4b.sh

if [ $SLURM_LOCALID -eq 0 ]; then
    gcloud storage rsync --recursive gs://$TEAM_BUCKET/$DATASET_PATH_GCP $DATASET_PATH_SSD
    mkdir -p $WEIGHTS_PATH_SSD && gcsfuse --only-dir $WEIGHTS_PATH_GCP $TEAM_BUCKET $WEIGHTS_PATH_SSD
fi

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model $TOKENIZER
    --data-path $(find $DATASET_PATH_SSD -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 128
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
    --save $WEIGHTS_PATH_SSD
    --save-interval 10000
    --load $WEIGHTS_PATH_SSD
    --eval-interval 1000
    --eval-iters 100
    --wandb-save-dir $SSD_SPACE
    --wandb-project "MoE-Research"
    --wandb-exp-name $SLURM_JOB_NAME.$SLURM_JOB_ID
    --tensorboard-dir $WEIGHTS_PATH_SSD
)

cd Megatron-LM
torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
    ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} ${DATA_ARGS[@]} ${TRAIN_ARGS[@]} ${LOG_ARGS[@]}

if [ $SLURM_LOCALID -eq 0 ]; then
    fusermount -u -z $WEIGHTS_PATH_SSD
    rm -rf $DATASET_PATH_SSD
fi
