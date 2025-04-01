#!/bin/bash
# Invoked by scripts/training/deepseek-v2-lite.sh

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

source configs/model/deepseek-v2-lite.sh
source configs/infra/deepseek-v2-lite.sh

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model $TOKENIZER
    --data-path $(find $DATASET_PATH -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 4
    --global-batch-size 32
    --lr 5e-4
    --min-lr 5e-5
    --lr-decay-style cosine
    --lr-warmup-fraction 0.01
    --train-iters 50
    --clip-grad 1.0
    --bf16
)

LOG_ARGS=(
    --log-interval 10
    --log-throughput
    --save $SSD_MOUNT
    --save-interval 80000
    --load $SSD_MOUNT
    --eval-interval 1000
    --eval-iters 100
    --wandb-save-dir $SSD_MOUNT
    --wandb-project "MoE-Research"
    --wandb-exp-name $SLURM_JOB_NAME.$JID
    --tensorboard-dir $SSD_MOUNT
)

PROFILE_OUT=$PWD/deepseek-v2-lite

cd Megatron-LM && nsys profile \
    --trace=cuda,nvtx \
    --output=$PROFILE_OUT \
    --force-overwrite=true \
    --capture-range=cudaProfilerApi \
    --capture-range-end=stop \
    --sample=none \
    torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
        ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} ${DATA_ARGS[@]} \
        ${TRAIN_ARGS[@]} ${LOG_ARGS[@]} \
        --profile \
        --profile-step-start=20 \
        --profile-step-end=25
