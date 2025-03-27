#!/bin/bash
# Download the DCLM dataset for the 1B-1x scale, which contains 28B training tokens.

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

source devconfig.sh
export WORKSPACE=$WORKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $WORKSPACE
export DISKSPACE=$DISKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $DISKSPACE
trap "rm -rf $WORKSPACE $DISKSPACE" EXIT

aws s3 ls --recursive s3://commoncrawl/contrib/datacomp/DCLM-baseline/global-shard_03_of_10/local-shard_1_of_10/ | while read -r line; do
    path=$(echo $line | awk '{print $4}')
    link=s3://commoncrawl/$path
    task=$WORKSPACE/"gs0310-ls110_$(basename $path).task"
    echo $link > $task
done

srun -W 0 scripts/dataset/functions/download_dclm28b_step1.sh
