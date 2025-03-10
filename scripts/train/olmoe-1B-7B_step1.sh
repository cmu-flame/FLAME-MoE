#!/bin/bash
# Invoked by scripts/train/olmoe-1B-7B.sh
# Adopted from the following:
# - https://huggingface.co/allenai/OLMoE-1B-7B-0924/blob/main/config.json
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md

# Author: Hao Kang
# Date: March 9, 2025

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1

# Generates a list of prefixes for each tokenized chunk and joins the names
# with spaces, as required by megatron/training/arguments.py
DATASET_PATH=$(find $DATASET_DIR/dclm-28B-olmoe/ -type f -name *.bin |
    xargs -I {} sh -c 'echo -n "$DATASET_DIR/dclm-28B-olmoe/$(basename {} .bin) "' |
        sed 's/ $//')

WEIGHTS_PATH=$WEIGHTS_DIR/olmoe-1B-7B

DISTRIBUTED_ARGS=(
    --nnodes $SLURM_NNODES
    --node_rank $SLURM_NODEID
    --nproc_per_node $SLURM_GPUS_ON_NODE
    --rdzv-id $SLURM_JOB_ID
    --rdzv-backend c10d
    --rdzv-endpoint $MASTER_ADDR:$MASTER_PORT
)

MODEL_ARGS=(
    --disable-bias-linear
    --seq-length 4096
    --max-position-embeddings 4096
    --num-layers 16
    --hidden-size 2048
    --ffn-hidden-size 1024
    --num-attention-heads 16
    --init-method-std 0.01
    --attention-dropout 0.0
    --hidden-dropout 0.0
    --normalization RMSNorm
    --position-embedding-type rope
    --swiglu
    --untie-embeddings-and-output-weights
    --group-query-attention
    --num-query-groups 8
    --no-masked-softmax-fusion
    --no-position-embedding
)

MOE_ARGS=(
    --num-experts 64
    --moe-router-load-balancing-type aux_loss
    --moe-router-topk 8
    --moe-aux-loss-coeff 1e-2
    --moe-grouped-gemm
)

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model allenai/OLMoE-1B-7B-0924
    --data-path $DATASET_PATH
    --split 90,5,5
)

TRAINING_ARGS=(
    --micro-batch-size 1
    --global-batch-size 128
    --lr 1e-4
    --train-iters 60000
    --lr-decay-iters 38400
    --lr-decay-style cosine
    --min-lr 1.0e-5
    --weight-decay 0.1
    --lr-warmup-iters 60
    --clip-grad 1.0
    --bf16
    --overlap-grad-reduce
    --overlap-param-gather
)

MODEL_PARALLEL_ARGS=(
    --tensor-model-parallel-size 1
    --expert-model-parallel-size 8
    --pipeline-model-parallel-size 1
    --sequence-parallel
    --use-distributed-optimizer
)

LOGGING_ARGS=(
    --log-interval 1
    --save-interval 10000
    --eval-interval 1000
    --eval-iters 10
    --save $WEIGHTS_PATH
    --load $WEIGHTS_PATH
    --tensorboard-dir "${WEIGHTS_PATH}/tensorboard"
    --no-load-optim
    --no-load-rng
)

if [ -n "${WANDB_API_KEY}" ]; then
    LOGGING_ARGS+=(
        --wandb-project MoE-Research
        --wandb-exp-name olmoe-1B-7B
    )
fi

cd Megatron-LM
torchrun ${DISTRIBUTED_ARGS[@]} pretrain_gpt.py \
    ${MODEL_ARGS[@]} \
    ${MOE_ARGS[@]} \
    ${DATA_ARGS[@]} \
    ${TRAINING_ARGS[@]} \
    ${MODEL_PARALLEL_ARGS[@]} \
    ${LOGGING_ARGS[@]}
