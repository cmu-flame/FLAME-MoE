#!/bin/bash
# Training launcher script for FLAME-MoE.

# Setup environment variables for training and debugging
export OMP_NUM_THREADS=16
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=true
export TORCH_NCCL_TRACE_BUFFER_SIZE=8
export TORCH_NCCL_DUMP_ON_TIMEOUT=1

# Setup required arguments to Megatron-LM
source configs/model/flame-moe.sh
source configs/train/flame-moe.sh

DATA_ARGS=(
    --seq-length 2048
    --data-path $(find $SSD_DATASET -type f -name '*.bin' -exec sh -c 'printf "1.0 %s " "${1%.bin}"' _ {} \; | sed 's/ $//')
    --split 90,5,5
)

SAVE_ARGS=(
    --log-interval 5
    --log-throughput
    --save $SSD_WEIGHTS
    --save-interval $SAVE_INTERVAL
    --load $SSD_WEIGHTS
    --eval-interval $EVAL_INTERVAL
    --wandb-save-dir $SSD_WEIGHTS
    --wandb-project $WANDB_PROJECT
    --wandb-exp-name $SLURM_JOB_ID
    --tensorboard-dir $SSD_WEIGHTS
)

# Start training with torchrun
cd Megatron-LM && torchrun "${TORCH_ARGS[@]}" pretrain_gpt.py \
    "${MODEL_ARGS[@]}" "${INFRA_ARGS[@]}" "${TRAIN_ARGS[@]}" "${DATA_ARGS[@]}" "${SAVE_ARGS[@]}" &
TORCHRUN_PID=$!

# Upload weights every 15 minutes while training is running
mkdir -p $SSD_WEIGHTS
(
    while kill -0 $TORCHRUN_PID 2>/dev/null; do
        until gcloud storage rsync --recursive $SSD_WEIGHTS/ $TRAIN_WEIGHTS/; do continue; done
        sleep 15m
    done
) &

# Final upload after training completes
wait $TORCHRUN_PID
until gcloud storage rsync --recursive $SSD_WEIGHTS/ $TRAIN_WEIGHTS/; do continue; done
