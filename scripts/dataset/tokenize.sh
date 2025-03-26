#!/bin/bash
# Tokenize the dataset using the specified tokenizer model.
# Usage: sbatch scripts/dataset/tokenize.sh <load-dir> <tokenizer> <save-dir>
# Please take a look at scripts/dataset/README.md for more details.

# Author: Hao Kang
# Date: March 25, 2025

#SBATCH --job-name=tokenize
#SBATCH --output=logs/%x-%A/subtask-%a.log

#SBATCH --array=0-3
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1
#SBATCH --mem=128G

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo "Usage: $0 <load-dir> <save-dir> <tokenizer>"
    echo "<load-dir>  : Directory containing *.jsonl files to tokenize"
    echo "<tokenizer> : HuggingFace tokenizer model to use"
    echo "<save-dir>  : Directory to save tokenized binaries and indices"
    exit 1
fi

srun -W 0 scripts/dataset/modules/tokenize_step1.sh $@
