#!/bin/bash
# Train dense-182M on DCLM-28B dataset.

# Author: Hao Kang
# Date: March 21, 2025

#SBATCH --job-name=dense-182M
#SBATCH --output=logs/dense-182M-%j.log
#SBATCH --time=2-00:00:00

#SBATCH --nodes=1
#SBATCH --gres=gpu:2
#SBATCH --cpus-per-task=64
#SBATCH --mem=256G

# Setup the environment.
source devconfig.sh
source devsecret.env
export MASTER_ADDR=$(hostname)
export MASTER_PORT=8000

# Dispatch the training.
srun -W 0 scripts/train/dense-182M_step1.sh
