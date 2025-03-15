#!/bin/bash
# Tokenize the Pile dataset using OLMoE tokenizer.

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

#SBATCH --nodes=4                  # Request 4 compute nodes
#SBATCH --tasks-per-node=1         # Request 1 task per node
#SBATCH --mem=64G                  # Request 64 GB of RAM per node
#SBATCH --cpus-per-task=32         # Request 32 CPU cores per task
#SBATCH --gres=gpu:1               # Request 1 GPU per node (required by Megatron)
#SBATCH --job-name=pile-olmoe      # Set the job name
#SBATCH --time=48:00:00            # Set the time limit
#SBATCH --output=logs/slurm-%j.out # Set the output file

# Setup the environment.
source devconfig.sh
export TASK_INDEX=$(mktemp -p $PWD)
trap "rm -f $TASK_INDEX" EXIT
mkdir -p $DATASET_DIR/pile-olmoe

# Tokenize the Pile dataset.
find $DATASET_DIR/pile -type f -name '*.jsonl' >$TASK_INDEX
srun -W 0 scripts/dataset/tokenize/pile-olmoe_step1.sh
