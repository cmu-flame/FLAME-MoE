#!/bin/bash

export OMP_NUM_THREADS=16
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=true

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
    --save-interval 2000
    --load $SSD_WEIGHTS
    --eval-interval 1000
    --wandb-save-dir $SSD_WEIGHTS
    --wandb-project $WANDB_PROJECT
    --wandb-exp-name $SLURM_JOB_ID
    --tensorboard-dir $SSD_WEIGHTS
)

host=$(hostname)
mkdir -p $SSD_WEIGHTS

cd Megatron-LM && torchrun "${TORCH_ARGS[@]}" pretrain_gpt.py \
    "${MODEL_ARGS[@]}" "${INFRA_ARGS[@]}" "${TRAIN_ARGS[@]}" "${DATA_ARGS[@]}" "${SAVE_ARGS[@]}" &

# Start a background upload loop while training runs
TORCHRUN_PID=$!
(
    while kill -0 $TORCHRUN_PID 2>/dev/null; do
        sleep 15m; i=1
        until gsutil -q -m rsync -r "$SSD_WEIGHTS" "$TRAIN_WEIGHTS"; do
            echo "[$host] Upload retry attempt $i"
            delay=$((2**i))
            [ $delay -gt 32 ] && delay=32
            sleep $delay
            i=$((i + 1))
        done
    done
) &

# Final upload after training finishes
wait $TORCHRUN_PID; i=1
until gsutil -m rsync -r "$SSD_WEIGHTS" "$TRAIN_WEIGHTS"; do
    echo "[$host] Final upload retry attempt $i"
    delay=$((2**i))
    [ $delay -gt 32 ] && delay=32
    sleep $delay
    i=$((i + 1))
done
