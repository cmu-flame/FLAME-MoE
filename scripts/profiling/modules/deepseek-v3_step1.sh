#!/bin/bash

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

source configs/model/deepseek-v3.sh
source configs/infra/deepseek-v3.sh

DATA_ARGS=(
    --seq-length 4096
    --vocab-size 129280
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model $TOKENIZER
    --data-path $(find $DATASET_PATH -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

TRAIN_ARGS=(
    --micro-batch-size 1
    --global-batch-size 8
    --lr 5e-4
    --min-lr 5e-5
    --lr-decay-style cosine
    --lr-warmup-fraction 0.01
    --train-iters 50
    --clip-grad 1.0
)

LOG_ARGS=(
    --log-interval 5
    --log-throughput
    --eval-iters 1
    --wandb-save-dir $SSD_MOUNT
    --wandb-project "MoE-Research-Profiling"
    --wandb-exp-name $SLURM_JOB_NAME.$SLURM_JOB_ID
    --tensorboard-dir $PROFILE_PATH
)

# Dispatch the training.
cd Megatron-LM && nsys profile \
    -s none -t nvtx,cuda \
    -o $PROFILE_PATH \
    --force-overwrite=true \
    --capture-range=cudaProfilerApi \
    --capture-range-end=stop \
    torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
        --profile \
        --profile-step-start=20 \
        --profile-step-end=25 \
        ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} \
        ${DATA_ARGS[@]} ${TRAIN_ARGS[@]} ${LOG_ARGS[@]} &

# Periodically synchronize checkpoints back to GCP while training.
TORCHRUN_PID=$!
if [ $SLURM_LOCALID -eq 0 ]; then
    (
        while kill -0 $TORCHRUN_PID 2>/dev/null; do
            gcloud storage rsync --recursive $PROFILE_PATH $GCP_PROFILE_PATH
            sleep 10m
        done
    ) &
fi
wait $TORCHRUN_PID
if [ $SLURM_LOCALID -eq 0 ]; then
    gcloud storage rsync --recursive $PROFILE_PATH $GCP_PROFILE_PATH
fi
