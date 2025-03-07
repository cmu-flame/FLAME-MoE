#!/bin/bash
# Tokenize the Pile dataset using GPT2BPETokenizer.

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 7, 2025

#SBATCH --nodes=2                  # Request 2 compute nodes
#SBATCH --tasks-per-node=2         # Request 2 tasks per node
#SBATCH --mem=64G                  # Request 64 GB of RAM per node
#SBATCH --cpus-per-task=32         # Request 32 CPU cores per task
#SBATCH --gres=gpu:1               # Request 1 GPU per node; required to load the Megatron
#SBATCH --job-name=pile-gpt2bpe    # Set the job name
#SBATCH --time=02:00:00            # Set the time limit
#SBATCH --output=logs/slurm-%j.out # Set the output file

# Setup the environment.
source devconfig.sh
export TASK_INDEX=$(mktemp -p $PWD)
trap "rm -f $TASK_INDEX" EXIT

# Download the vocabulary files.
if [ ! -f "$DATASET_DIR/gpt2-vocab.json" ]; then
    wget -O $DATASET_DIR/gpt2-vocab.json -q https://huggingface.co/gpt2/resolve/main/vocab.json
fi
if [ ! -f "$DATASET_DIR/gpt2-merges.txt" ]; then
    wget -O $DATASET_DIR/gpt2-merges.txt -q https://huggingface.co/gpt2/resolve/main/merges.txt
fi

# Tokenize the Pile dataset.
find $DATASET_DIR/pile -type f -name '*.jsonl' >$TASK_INDEX
srun -W 0 scripts/dataset/tokenize/pile-gpt2bpe_step1.sh
