#!/bin/bash

# GCPBUCKET is the object storage for data and models.
# All team members should have read access to this bucket.
export GCPBUCKET=gs://cmu-gpucloud-haok/MoE-Research

# WORKSPACE are mounted with NFS which are shared among all nodes.
# DISKSPACE are mounted with local SSD which are local to each node.
export WORKSPACE=/home/$USER/MoE-Research
export DISKSPACE=/mnt/localssd/$USER/MoE-Research

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
