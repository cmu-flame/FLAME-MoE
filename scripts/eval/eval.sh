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

PROJECT_NAME="llama_182m_moe_dclm"
WEIGHTS_PATH=$WEIGHTS_DIR/$PROJECT_NAME

echo "Testing $WEIGHTS_PATH"
cd lm-evaluation-harness
PYTHONPATH=$WORKSPACE/lm-evaluation-harness torchrun --nproc-per-node=1 --master_addr=localhost --master_port=6000 -m lm_eval \
    --model megatron_lm \
    --model_args path=$WEIGHTS_PATH,tokenizer_model=openai-community/gpt2 \
    --tasks "arc_easy,arc_challenge,boolq,hellaswag,winogrande,piqa,race,lambada_openai" \
    --output_path $WORKSPACE/results/$PROJECT_NAME \
    --batch_size 16
