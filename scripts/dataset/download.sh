#!/bin/bash
# Download the desired dataset.
# Usage: scripts/dataset/download.sh <dataset>

# Author: Hao Kang
# Date: March 9, 2025

#SBATCH --job-name=download
#SBATCH --output=logs/%x-%j.log
#SBATCH --time=2-00:00:00
#SBATCH --partition=preempt

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4

if [ -z $1 ]; then
    echo "Usage: scripts/dataset/download.sh <dataset>"
    echo "Arguments:"
    echo "    <dataset>: The dataset to download. Options are:"
    echo "        - 'dclm28b': The DCLM-28B dataset."
    exit 1
fi

export DATASET=$1

source devconfig.sh
source devsecret.sh
trap "rm -rf $NFS_MOUNT $SSD_MOUNT" EXIT

download_dclm28b() {
    # Each task file contains the S3 link and the local file path.
    prefix=s3://commoncrawl/contrib/datacomp/DCLM-baseline/global-shard_03_of_10/local-shard_1_of_10/
    aws s3 ls $prefix | while read -r line; do
        name=$(echo $line | awk '{print $4}')
        link=$prefix$name
        name=gs0310-ls110_$name
        file=$SSD_MOUNT/$name
        task=$NFS_MOUNT/$name.task
        echo $link >> $task
        echo $file >> $task
    done
    # Dispatch the tasks to the nodes.
    srun -W 0 "gcsfuse --only-dir MoE-Research $BUCKET $GCP_MOUNT"
    srun -W 0 scripts/dataset/modules/download_dclm_step1.sh
}

case $DATASET in
    dclm28b)
        download_dclm28b
        ;;
    *)
        echo "Unknown dataset: $1"
        exit 1
esac
