#!/bin/bash
# Evaluation.

# Author: Zichun Yu
# Date: March 10, 2025

#SBATCH --job-name=eval            # Set the job name
#SBATCH --output=logs/eval_%j.out  # Set the output file
#SBATCH --nodes=1                  # Request 1 compute nodes
#SBATCH --gres=gpu:1               # Request 1 GPU devices per node
#SBATCH --cpus-per-task=128        # Request 128 CPU cores per task
#SBATCH --mem=512G                 # Request 512 GB of RAM per node
#SBATCH --time=2-00:00:00          # Set the time limit

# Setup the environment.
source devconfig.sh
export CUDA_DEVICE_MAX_CONNECTIONS=1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
export HF_DATASETS_TRUST_REMOTE_CODE=true

PROJECT_NAME="llama_182m_moe_dclm"
WEIGHTS_PATH=$WEIGHTS_DIR/$PROJECT_NAME

# llama-182M-1.4B
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
    --tokenizer-type HuggingFaceTokenizer
    --tokenizer-model openai-community/gpt2
)

MOE_ARGS=(
    --num-experts 8
    --moe-router-topk 1
    --moe-router-load-balancing-type aux_loss
    --moe-aux-loss-coeff 1e-2
    --moe-token-dispatcher-type alltoall
    --moe-router-pre-softmax
    --moe-grouped-gemm
    --moe-layer-recompute
)

# olmoe-1B-7B
# MODEL_ARGS=(
#     --disable-bias-linear
#     --seq-length 4096
#     --max-position-embeddings 4096
#     --num-layers 16
#     --hidden-size 2048
#     --ffn-hidden-size 1024
#     --num-attention-heads 16
#     --init-method-std 0.01
#     --attention-dropout 0.0
#     --hidden-dropout 0.0
#     --normalization RMSNorm
#     --position-embedding-type rope
#     --swiglu
#     --untie-embeddings-and-output-weights
#     --group-query-attention
#     --num-query-groups 8
#     --no-masked-softmax-fusion
#     --no-position-embedding
#     --tokenizer-type HuggingFaceTokenizer \
#     --tokenizer-model allenai/OLMoE-1B-7B-0924 \
# )

# MOE_ARGS=(
#     --num-experts 64
#     --moe-router-topk 8
#     --moe-router-load-balancing-type aux_loss
#     --moe-aux-loss-coeff 1e-2
#     --moe-grouped-gemm
# )

echo "Testing $WEIGHTS_PATH"
cd lm-evaluation-harness
PYTHONPATH=$WORKSPACE/Megatron-LM torchrun --nproc-per-node=1 --master_addr=localhost --master_port=6000 -m lm_eval \
    ${MODEL_ARGS[@]} ${MOE_ARGS[@]} \
    --bf16 \
    --micro-batch-size 1 \
    --max-tokens-to-oom 10000000 \
    --seed 42 \
    --load $WEIGHTS_PATH \
    --model megatron_lm \
    --tasks "arc_easy,arc_challenge,boolq,hellaswag,winogrande,piqa,race,lambada_openai" \
    --output_path $WORKSPACE/results/$PROJECT_NAME \
    --batch_size 16
