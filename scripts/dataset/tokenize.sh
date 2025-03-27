#!/bin/bash
# Tokenize the dataset using the specified tokenizer.
# Usage: scripts/dataset/tokenize.sh <load-path> <tokenizer> <save-path>

# Author: Hao Kang
# Date: March 26, 2025

#SBATCH --job-name=tokenize
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=4
#SBATCH --ntasks-per-node=2
#SBATCH --mem=64G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo "Usage: $0 <load-path> <tokenizer> <save-path>"
    echo "Arguments:"
    echo "    <load-path> : GCP bucket path containing *.jsonl files to tokenize"
    echo "    <tokenizer> : HuggingFace tokenizer model to use"
    echo "    <save-path> : GCP bucket path to save tokenized binaries and indices"
    exit 1
fi

# Set up the runtime environment
source devconfig.sh
source devsecret.env
export WORKSPACE=$WORKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $WORKSPACE
export DISKSPACE=$DISKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $DISKSPACE
trap "rm -rf $WORKSPACE $DISKSPACE" EXIT

# Discover the files in the GCS and create task files.
# Each task file contains the GCS link and the local file path.
gcloud storage ls $GCPBUCKET/$1 | while read -r line; do
    link=$line
    name=$(basename $line)
    file=$DISKSPACE/$name
    task=$WORKSPACE/$name.task
    echo $link >> $task
    echo $file >> $task
done

# Dispatch the tasks to the nodes.
srun -W 0 scripts/dataset/functions/tokenize.sh $@
