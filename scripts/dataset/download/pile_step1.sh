#!/bin/bash
# Invoked by scripts/dataset/download/pile.sh

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 6, 2025

split $TASK_INDEX -n l/$((SLURM_PROCID + 1))/$SLURM_NTASKS |
    xargs -I {} sh -c 'echo "Downloading: {}"; wget -P $DATASET_DIR/pile -q {}'
