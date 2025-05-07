#!/bin/bash

#SBATCH --job-name=debug
#SBATCH --output=logs/%x/%j.log

#SBATCH --partition=flame
#SBATCH --time=2-00:00:00
#SBATCH --qos=flame-t1b_g1_qos

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

srun -W 0 scripts/debug/modules/acquire_step1.sh
srun -W 0 scripts/debug/modules/acquire_step2.sh
