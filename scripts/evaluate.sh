#!/bin/bash
# Evaluation.

# Author: Zichun Yu
# Date: March 10, 2025

#SBATCH --job-name=eval               # Set the job name
#SBATCH --output=logs/evaluate-%j.log # Set the output file
#SBATCH --nodes=1                     # Request 1 compute nodes
#SBATCH --gres=gpu:1                  # Request 1 GPU devices per node
#SBATCH --cpus-per-task=128           # Request 128 CPU cores per task
#SBATCH --mem=512G                    # Request 512 GB of RAM per node
#SBATCH --time=2-00:00:00             # Set the time limit

source devconfig.sh
source devsecret.env

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
export HF_DATASETS_TRUST_REMOTE_CODE=true

source configs/model/$MODEL.sh
gcloud storage cp -r $GCP_WEIGHTS_DIR/$MODEL/$JOBID/* $SSD_MOUNT/
echo $ITERS > $SSD_MOUNT/latest_checkpointed_iteration.txt

cd lm-evaluation-harness && PYTHONPATH=/home/$USER/MoE-Research/Megatron-LM torchrun \
    --nproc-per-node=1 --master_addr=localhost --master_port=6000 -m lm_eval \
    ${MODEL_ARGS[@]} \
    --bf16 \
    --micro-batch-size 1 \
    --max-tokens-to-oom 10000000 \
    --seed 42 \
    --load $SSD_MOUNT \
    --model megatron_lm \
    --tasks "arc_easy,arc_challenge,boolq,hellaswag,winogrande,piqa,race,lambada_openai" \
    --output_path /dev/null \
    --batch_size 16 \
    --tokenizer-type HuggingFaceTokenizer \
    --tokenizer-model openai-community/gpt2
