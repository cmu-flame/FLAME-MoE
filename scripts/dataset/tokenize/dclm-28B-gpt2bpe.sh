#!/bin/bash
# Tokenize the DCLM-28B dataset using GPT2BPETokenizer.

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

#SBATCH --nodes=4                   # Request 4 compute nodes
#SBATCH --tasks-per-node=4          # Request 4 tasks per node
#SBATCH --mem=32G                   # Request 32 GB of RAM per node
#SBATCH --cpus-per-task=32          # Request 32 CPU cores per task
#SBATCH --gres=gpu:1                # Request 1 GPU per node; required to load the Megatron
#SBATCH --job-name=dclm-28B-gpt2bpe # Set the job name
#SBATCH --time=48:00:00             # Set the time limit
#SBATCH --output=logs/slurm-%j.out  # Set the output file

# Setup the environment.
source devconfig.sh
export TASK_INDEX=$(mktemp -p $PWD)
trap "rm -f $TASK_INDEX" EXIT
mkdir -p $DATASET_DIR/dclm-28B-gpt2bpe

# Download the vocabulary files.
if [ ! -f "$DATASET_DIR/gpt2-vocab.json" ]; then
    wget -O $DATASET_DIR/gpt2-vocab.json -q https://huggingface.co/gpt2/resolve/main/vocab.json
fi
if [ ! -f "$DATASET_DIR/gpt2-merges.txt" ]; then
    wget -O $DATASET_DIR/gpt2-merges.txt -q https://huggingface.co/gpt2/resolve/main/merges.txt
fi

# Tokenize the DCLM-28B dataset.
find $DATASET_DIR/dclm-28B -type f -name '*.jsonl' >$TASK_INDEX
srun -W 0 scripts/dataset/tokenize/dclm-28B-gpt2bpe_step1.sh
