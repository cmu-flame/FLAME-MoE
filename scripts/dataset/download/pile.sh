#!/bin/bash
# Download the Pile dataset.

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 6, 2025

#SBATCH --nodes=4                  # Request 4 compute nodes
#SBATCH --tasks-per-node=2         # Request 2 tasks per node
#SBATCH --cpus-per-task=2          # Request 2 CPU core per task
#SBATCH --mem=32G                  # Request 32 GB of RAM per node
#SBATCH --job-name=pile            # Set the job name
#SBATCH --time=00:30:00            # Set the time limit
#SBATCH --output=logs/slurm-%j.out # Set the output file

# Setup the environment.
source devconfig.sh
export TASK_INDEX=$(mktemp -p $TEMP_DIR)
export TASK_SPACE=$DATASET_DIR/pile
trap 'rm -f "$TASK_INDEX"' EXIT
mkdir -p $TASK_SPACE

# Download the Pile dataset.
HOSTING=https://huggingface.co/datasets/monology/pile-uncopyrighted
for i in $(seq -w 00 07); do
    echo $HOSTING/resolve/main/train/$i.jsonl.zst >>$TASK_INDEX
done
srun -W 0 scripts/dispatch.sh scripts/dataset/download/pile_step1.sh $TASK_INDEX $TASK_SPACE

# Extract the Pile dataset.
find $TASK_SPACE -type f -name '*.jsonl.zst' >$TASK_INDEX
srun -W 0 scripts/dispatch.sh scripts/dataset/download/pile_step2.sh $TASK_INDEX $TASK_SPACE
