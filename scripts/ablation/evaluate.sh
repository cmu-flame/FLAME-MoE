#!/bin/bash

#SBATCH --job-name=evaluate
#SBATCH --output=logs/%x/%A/%j/stdout.log

#SBATCH --partition=flame
#SBATCH --time=07-00:00:00
#SBATCH --qos=flame-t1b_g1_qos
#SBATCH --array=0-79%8

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

source scripts/config.sh
source scripts/secret.sh

# all 3e19 configs
configs=(
    # "29638"
    # "29641"
    # "29646"
    # "29648"
    # "29649"
    # "29651"
    # "29652"
    # "29653"
    # "29659"
    " 2048 10944 1408 15 [0]*1+[1]*14 29927"
    " 2048 10944 1408 18 [0]*1+[1]*17 29940"
    " 1024  5472  704 18 [0]*1+[1]*17 29944"
    " 1024  5472  704 15 [0]*1+[1]*14 29945"
    " 1536  8208 1056 18 [0]*1+[1]*17 29950"
    " 1536  8208 1056 15 [0]*1+[1]*14 29951"
    "  512  2736  352 12 [0]*1+[1]*11 29953"
)

i=0
for config in "${configs[@]}"; do
  read -r hidden_size ffn_hidden_size moe_ffn_hidden_size num_layers moe_layer_freq jobid <<< "$config"
    if [[ $SLURM_ARRAY_TASK_ID -eq $i ]]; then
        export HIDDEN_SIZE=$hidden_size
        export FFN_HIDDEN_SIZE=$ffn_hidden_size
        export MOE_FFN_HIDDEN_SIZE=$moe_ffn_hidden_size
        export NUM_LAYERS=$num_layers
        export MOE_LAYER_FREQ=$moe_layer_freq
        export JOBID=$jobid
        bash scripts/evaluate.sh
    fi
    ((i++))
done
