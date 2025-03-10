#!/bin/bash
# Download the DCLM dataset for the 1B-1x scale, which contains 28B tokens.

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

#SBATCH --nodes=4                  # Request 4 compute nodes
#SBATCH --ntasks-per-node=32       # Run 32 tasks per node
#SBATCH --mem=16G                  # Request 16 GB of RAM per node
#SBATCH --cpus-per-task=2          # Request 2 CPU core per task
#SBATCH --job-name=dclm-28B        # Set the job name
#SBATCH --time=48:00:00            # Set the time limit
#SBATCH --output=logs/slurm-%j.out # Set the output file

# Setup the environment.
source devconfig.sh
export TASK_INDEX=$(mktemp -p $PWD)
trap "rm -f $TASK_INDEX" EXIT
mkdir -p $DATASET_DIR/dclm-28B

# Download the DCLM dataset.
BUCKET_URL=s3://commoncrawl/contrib/datacomp/DCLM-baseline/global-shard_03_of_10/local-shard_1_of_10/
aws s3 ls --recursive $BUCKET_URL | awk -v bucket="s3://commoncrawl" '{print bucket "/" $4}' >$TASK_INDEX
srun --wait 0 bash scripts/dataset/download/dclm-28B_step1.sh

# Extract the DCLM dataset.
find $DATASET_DIR/dclm-28B -type f -name "*.jsonl.zstd" | sort >$TASK_INDEX
srun --wait 0 bash scripts/dataset/download/dclm-28B_step2.sh
