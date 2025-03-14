#!/bin/bash
# Invoked by scripts/dataset/download/pile.sh

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 6, 2025

retry() {
    for i in {1..3}; do
        echo "Extracting $1 (Attempt $i of 3)"
        unzstd -q $1 && rm -f $1 && break
        echo "Failed to extract $1, retrying..." && sleep 5
    done
}

split $TASK_INDEX -n l/$((SLURM_PROCID + 1))/$SLURM_NTASKS | while read -r line; do
    retry $line
done
