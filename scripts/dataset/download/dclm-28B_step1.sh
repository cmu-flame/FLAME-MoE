#!/bin/bash
# Invoked by scripts/dataset/download/dclm-28B.sh

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

split $TASK_INDEX -n l/$((SLURM_PROCID + 1))/$SLURM_NTASKS |
    xargs -I {} sh -c 'aws s3 cp {} $DATASET_DIR/dclm-28B/$(basename {})'
