#!/bin/bash
# Compute the router saturation for FLAME-MoE-721M-3.8B

#SBATCH --job-name=router-saturation-721m
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
export TRAIN_JOB_ID=31067
export TRAIN_JOB_NAME=flame-moe-721m
bash scripts/empirical_analysis/modules/router_saturation_step1.sh

# process each top-k for FLAME-MoE-721M-3.8B
for moe_router_topk in 1 2 4 6; do
    for layer_number in {2..12}; do
        actives_pattern="$SSD_MOUNT/actives/*/$layer_number"
        results_path=results/router-saturation/flame-moe-721m/$moe_router_topk.pkl
        python3 scripts/empirical_analysis/modules/router_saturation_step2.py --moe-router-topk $moe_router_topk --actives-pattern "$actives_pattern" --results-path $results_path
    done
done
