#!/bin/bash
# Compute the expert coactivation for FLAME-MoE-290M-1.3B

#SBATCH --job-name=expert-coactivation-290m
#SBATCH --output=logs/%x/%j.log

#SBATCH --partition=flame
#SBATCH --time=14-00:00:00
#SBATCH --qos=flame-t1b_g1_qos

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

source scripts/config.sh

# load the captured actives via google cloud
export TRAIN_JOB_ID=31066
export TRAIN_JOB_NAME=flame-moe-290m
bash scripts/empirical_analysis/modules/expert_coactivation_step1.sh

# process each layer inside each checkpoint for FLAME-MoE-290M-1.3B
find $SSD_MOUNT/actives -mindepth 2 -maxdepth 2 -type d | while read -r actives_path; do
    results_path=results/expert-coactivation/flame-moe-290m/$(basename $(dirname $actives_path))/$(basename $actives_path).pkl
    python3 scripts/empirical_analysis/modules/expert_coactivation_step2.py --actives-path $actives_path --results-path $results_path
done
