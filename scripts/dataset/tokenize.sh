#!/bin/bash
# Tokenize the dataset using the specified tokenizer.
# Usage: scripts/dataset/tokenize.sh

# Author: Hao Kang
# Date: March 9, 2025

#SBATCH --job-name=tokenize
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=4
#SBATCH --ntasks-per-node=2
#SBATCH --mem=64G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1

source devconfig.sh
source devsecret.sh
trap "rm -rf $NFS_SPACE $SSD_SPACE" EXIT

# Each task file contains the GCS link and the local file path.
gcloud storage ls $GCPBUCKET/$1 | while read -r line; do
    link=$line
    name=$(basename $line)
    file=$SSD_SPACE/$name
    task=$NFS_SPACE/$name.task
    echo $link >> $task
    echo $file >> $task
done
# Dispatch the tasks to the nodes.
srun -W 0 scripts/dataset/modules/tokenize_step1.sh
