#!/bin/bash

# Setup the runtime environment.
export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

# Load the configurations.
source configs/model/deepseek-v3.sh
source configs/infra/deepseek-v3.sh

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
)

LOG_ARGS=(
    --log-interval 5
    --log-throughput
    --save $WEIGHTS_PATH
    --save-interval 50
    --load $WEIGHTS_PATH
    --eval-interval 50
    --wandb-save-dir $SSD_MOUNT
    --wandb-project "MoE-Research"
    --wandb-exp-name $SLURM_JOB_NAME.$SLURM_JOB_ID
    --tensorboard-dir $WEIGHTS_PATH
)

# Dispatch the training.
cd Megatron-LM && torchrun ${TORCH_ARGS[@]} pretrain_gpt.py \
    ${MODEL_ARGS[@]} ${INFRA_ARGS[@]} \
    ${DATA_ARGS[@]} ${TRAIN_ARGS[@]} ${LOG_ARGS[@]} &

# Periodically synchronize checkpoints back to GCP while training.
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
