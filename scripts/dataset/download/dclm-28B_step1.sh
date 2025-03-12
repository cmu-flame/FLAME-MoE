#!/bin/bash
# Invoked by scripts/dataset/download/dclm-28B.sh

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

retry() {
    for i in {1..3}; do
        echo "Downloading $1 (Attempt $i of 3)"
        aws s3 cp $1 $DATASET_DIR/dclm-28B/$(basename $1) > /dev/null 2>&1 && break
        echo "Failed to download $1, retrying..." && sleep 5
    done
}

split $TASK_INDEX -n l/$((SLURM_PROCID + 1))/$SLURM_NTASKS | while read -r line; do
    retry $line
done
