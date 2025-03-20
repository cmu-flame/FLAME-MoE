#!/bin/bash
# Train OLMoE-1B-7B on DCLM-28B dataset.

# Author: Hao Kang
# Date: March 9, 2025

#SBATCH --job-name=olmoe-1B-7B     # Set the job name
#SBATCH --output=logs/olmoe-%j.log # Set the output file
#SBATCH --time=2-00:00:00          # Set the time limit

#SBATCH --nodes=4                  # Request 4 compute nodes
#SBATCH --gres=gpu:8               # Request 8 GPU devices per node
#SBATCH --cpus-per-task=32         # Request 32 CPU cores per task
#SBATCH --mem=256G                 # Request 256 GB of RAM per node

# Setup the environment.
source devconfig.sh
source devsecret.env
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Dispatch the training.
srun -W 0 scripts/train/olmoe-1B-7B_step1.sh
