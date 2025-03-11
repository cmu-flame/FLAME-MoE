#!/bin/bash
# Train OLMoE-1B-7B on DCLM-28B dataset.

# Author: Hao Kang
# Date: March 9, 2025

#SBATCH --nodes=4                  # Request 4 compute nodes
#SBATCH --tasks-per-node=8         # Request 8 tasks per node
#SBATCH --cpus-per-task=32         # Request 32 CPU cores per task
#SBATCH --mem=256G                 # Request 256 GB of RAM per node
#SBATCH --gres=gpu:8               # Request 8 GPU devices per node
#SBATCH --job-name=olmoe-1B-7B     # Set the job name
#SBATCH --time=48:00:00            # Set the time limit
#SBATCH --output=logs/slurm-%j.out # Set the output file

# Setup the environment.
source devconfig.sh
source devsecret.env
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Dispatch the training.
srun -W 0 scripts/train/olmoe-1B-7B_step1.sh
