#!/bin/bash
# Train llama-182M-1.4B on DCLM-28B dataset.

# Author: Zichun Yu
# Date: March 10, 2025

#SBATCH --job-name=llama-182M-1.4B # Set the job name
#SBATCH --output=logs/llama-%j.log # Set the output file
#SBATCH --time=2-00:00:00          # Set the time limit

#SBATCH --nodes=1                  # Request 1 compute node
#SBATCH --gres=gpu:8               # Request 8 GPU devices per node
#SBATCH --cpus-per-task=64         # Request 64 CPU cores per task
#SBATCH --mem=256G                 # Request 256 GB of RAM per node

# Setup the environment.
source devconfig.sh
source devsecret.env
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Dispatch the training.
srun -W 0 scripts/train/llama-182M-1.4B_step1.sh
