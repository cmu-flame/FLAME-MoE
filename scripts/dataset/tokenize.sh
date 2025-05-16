#!/bin/bash

#SBATCH --job-name=tokenize
#SBATCH --output=logs/%x/%j.log

#SBATCH --partition=flame
#SBATCH --time=00-02:00:00
#SBATCH --qos=flame-t1b_g1_qos

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem=512G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1

# Setup the runtime environment.
source devconfig.sh
source devsecret.sh

# Ensure cleanup of temporary directories on exit.
trap "rm -rf $NFS_MOUNT $SSD_MOUNT" EXIT

# Grab all the files to be tokenized and store into the parameter queue.
gcloud storage ls $GCP_DATASET_DIR/$DATASET/textfiles/ | while read -r line; do
    link=$line
    name=$(basename $line)
    file=$SSD_MOUNT/$name
    task=$NFS_MOUNT/$name.task
    echo $link >> $task
    echo $file >> $task
done

# Dispatch the tokenization.
srun -W 0 scripts/dataset/modules/tokenize_step1.sh
