#!/bin/bash
# Download the Pile dataset.

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 6, 2025

#SBATCH --nodes=4                  # Request 4 compute nodes
#SBATCH --tasks-per-node=2         # Request 2 tasks per node
#SBATCH --mem=16G                  # Request 16 GB of RAM per node
#SBATCH --cpus-per-task=2          # Request 2 CPU cores per task
#SBATCH --job-name=pile            # Set the job name
#SBATCH --time=48:00:00            # Set the time limit
#SBATCH --output=logs/slurm-%j.out # Set the output file

# Setup the environment.
source devconfig.sh
export TASK_INDEX=$(mktemp -p $PWD)
trap "rm -f $TASK_INDEX" EXIT
mkdir -p $DATASET_DIR/pile

# Download the Pile dataset.
HOSTING=https://huggingface.co/datasets/monology/pile-uncopyrighted
for i in $(seq -w 08 10); do
    echo $HOSTING/resolve/main/train/$i.jsonl.zst >>$TASK_INDEX
done
srun -W 0 scripts/dataset/download/pile_step1.sh

# Extract the Pile dataset.
find $DATASET_DIR/pile -type f -name "*.jsonl.zst" >$TASK_INDEX
srun -W 0 scripts/dataset/download/pile_step2.sh
