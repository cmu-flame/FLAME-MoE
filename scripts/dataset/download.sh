#!/bin/bash
# Download the desired dataset.
# Usage: scripts/dataset/download.sh <dataset>

# Author: Hao Kang
# Date: March 26, 2025

#SBATCH --job-name=download
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --mem=32G
#SBATCH --cpus-per-task=2

# Check if the dataset argument is provided
# If not, display usage instructions and exit
if [ -z $1 ]; then
    echo "Usage: scripts/dataset/download.sh <dataset>"
    echo "Arguments:"
    echo "    <dataset>: The dataset to download. Options: dclm28b"
    exit 1
fi

# Set up the development environment
source devconfig.sh
source devsecret.env

# Set up the workspace directory for the current SLURM job
export WORKSPACE=$WORKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $WORKSPACE

# Set up the disk space directory for the current SLURM job
export DISKSPACE=$DISKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $DISKSPACE

# Ensure cleanup of workspace and disk space directories on script exit
trap "rm -rf $WORKSPACE $DISKSPACE" EXIT

# Function to handle downloading the DCLM28B dataset
# This function creates task files for each shard and dispatches them to nodes
download_dclm28b() {
    aws s3 ls --recursive s3://commoncrawl/contrib/datacomp/DCLM-baseline/global-shard_03_of_10/local-shard_1_of_10/ | while read -r line; do
        path=$(echo $line | awk '{print $4}')
        link=s3://commoncrawl/$path
        task=$WORKSPACE/"gs0310-ls110_$(basename $path).task"
        echo $link > $task
    done
    srun -W 0 scripts/dataset/functions/download_dclm28b.sh
}

# Determine which dataset to handle based on the argument provided
case $1 in
    dclm28b)
        download_dclm28b
        ;;
    *)
        echo "Unknown dataset: $1"
        exit 1
esac
