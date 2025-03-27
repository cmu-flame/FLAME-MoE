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

if [ -z $1 ]; then
    echo "Usage: scripts/dataset/download.sh <dataset>"
    echo "Arguments:"
    echo "    <dataset>: The dataset to download. Options: dclm28b"
    exit 1
fi

source devconfig.sh
source devsecret.env

export WORKSPACE=$WORKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $WORKSPACE
export DISKSPACE=$DISKSPACE/slurm-$SLURM_JOB_ID
mkdir -p $DISKSPACE
trap "rm -rf $WORKSPACE $DISKSPACE" EXIT

download_dclm28b() {
    prefix=s3://commoncrawl/contrib/datacomp/DCLM-baseline/global-shard_03_of_10/local-shard_1_of_10/
    aws s3 ls $prefix | while read -r line; do
        name=$(echo $line | awk '{print $4}')
        name=gs0310-ls110_$name
        task=$WORKSPACE/$name.task
        echo $prefix$name >> $task
        echo $DISKSPACE/$name >> $task
    done
    srun -W 0 scripts/dataset/functions/download_dclm.sh
}

case $1 in
    dclm28b)
        download_dclm28b
        ;;
    *)
        echo "Unknown dataset: $1"
        exit 1
esac
