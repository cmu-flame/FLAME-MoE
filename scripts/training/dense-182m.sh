#!/bin/bash
# Train dense-182m model on the desired dataset.
# Usage: scripts/train/dense-182m.sh <tokenizer> <dataset-path> <weights-path>

# Author: Hao Kang
# Date: March 21, 2025

#SBATCH --job-name=dense-182m
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=128G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo "Usage: scripts/train/dense-182m.sh <tokenizer> <dataset-path> <weights-path>"
    echo "Arguments:"
    echo "    <tokenizer>    : HuggingFace tokenizer model to use"
    echo "    <dataset-path> : GCP bucket path to load the tokenized dataset"
    echo "    <weights-path> : GCP bucket path to save the model weights"
    exit 1
fi

export TOKENIZER=$1
export DATASET_PATH=$2
export WEIGHTS_PATH=$3

source devconfig.sh
source devsecret.env

export WORKSPACE=$WORKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $WORKSPACE
export DISKSPACE=$DISKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $DISKSPACE
trap "rm -rf $WORKSPACE $DISKSPACE" EXIT

export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

srun -W 0 scripts/training/modules/dense-182m_step1.sh $@
srun -W 0 scripts/training/modules/dense-182m_step2.sh $@
