#!/bin/bash
# Invoked by scripts/train/llama-182M-1.4B.sh
# Adopted from the following:
# - https://github.com/thu-ml/ReMoE/blob/main/scripts/train_llama_182m_moe.sh
# - https://github.com/NVIDIA/Megatron-LM/blob/main/megatron/core/transformer/moe/README.md

# Author: Zichun Yu
# Date: March 10, 2025

export CUDA_DEVICE_MAX_CONNECTIONS=1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

# 512 * 1k * 60k = 30b tokens.
TRAIN_ITERS=${2:-"60000"}
MICRO_BATCH_SIZE=${3:-"16"}
NUM_EXPERTS=${4:-"8"}
GRANILARITY=${5:-"1"}
PROJECT_NAME=${6:-"llama_182m_moe_dclm"}

DATASET_PATH=$(find $DATASET_DIR/dclm-28B-gpt2bpe/ -type f -name *.bin | 
    xargs -I {} sh -c "echo -n \"$DATASET_DIR/dclm-28B-gpt2bpe/\$(basename {} .bin) \"" |
        sed 's/ $//')
WEIGHTS_PATH=$WEIGHTS_DIR/$PROJECT_NAME

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
    --seq-length 1024
    --max-position-embeddings 1024
    --num-layers 12
    --hidden-size 768
    --ffn-hidden-size $((768 * 4))
    --num-attention-heads 12
    --init-method-std 0.01
    --attention-dropout 0.0
    --hidden-dropout 0.0
    --normalization RMSNorm
    --position-embedding-type rope
    --swiglu
    --untie-embeddings-and-output-weights
    --group-query-attention
    --num-query-groups 4
    --no-masked-softmax-fusion
    --no-position-embedding
    --rotary-base 1000000
    --use-flash-attn
)

MOE_ARGS=(
    --num-experts $NUM_EXPERTS
    --moe-router-topk 1
    --moe-router-load-balancing-type aux_loss
    --moe-aux-loss-coeff 1e-2
    --moe-token-dispatcher-type alltoall
    --overlap-param-gather
    --overlap-grad-reduce
    --moe-router-pre-softmax
    --moe-grouped-gemm
    --moe-layer-recompute
)

DATA_ARGS=(
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model openai-community/gpt2
    --data-path $DATASET_PATH
    --split 90,5,5
)

TRAINING_ARGS=(
    --micro-batch-size $MICRO_BATCH_SIZE
    --global-batch-size 512
    --lr 5e-4
    --train-iters $TRAIN_ITERS
    --lr-decay-style cosine
    --min-lr 5e-5
    --lr-warmup-fraction 0.01
    --clip-grad 1.0
    --bf16
)

MODEL_PARALLEL_ARGS=(
    --tensor-model-parallel-size 1
    --pipeline-model-parallel-size 1
    --expert-model-parallel-size 1
    --use-distributed-optimizer
    --sequence-parallel
)

LOGGING_ARGS=(
    --log-interval 10
    --log-throughput 
    --save-interval 5000
    --eval-interval 1000
    --eval-iters 100
    --save $WEIGHTS_PATH
    --ckpt-format torch
    --load $WEIGHTS_PATH
    --tensorboard-dir "${WEIGHTS_PATH}/tensorboard"
)

if [ -n "${WANDB_API_KEY}" ]; then
    LOGGING_ARGS+=(
        --wandb-project "MoE-Pretraining"
        --wandb-exp-name $PROJECT_NAME
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
