#!/bin/bash

#SBATCH --job-name=flame-moe-ablation
#SBATCH --output=logs/%x/%A/%j/stdout.log

#SBATCH --partition=flame
#SBATCH --time=07-00:00:00
#SBATCH --qos=flame-t1b_g1_qos
#SBATCH --array=0-47%8

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

source scripts/prepare.sh
source scripts/secrets.sh

configs=(
    "  256  1368  176  6  [0]*1+[1]*5  32 1  14260 6e18"
    "  768  4104  528  6  [0]*1+[1]*5  16 1   3258 6e18"
    "  512  2736  352  6  [0]*1+[1]*5  32 1   5799 6e18"
    "  512  2736  352  9  [0]*1+[1]*8  16 1   4848 6e18"
    "  256  1368  176  9  [0]*1+[1]*8  32 1  12726 6e18"
    "  768  4104  528  9  [0]*1+[1]*8   8 1   2611 6e18"
    " 1536  8208 1056 12 [0]*1+[1]*11   4 1    662 6e18"
    " 1024  5472  704 12 [0]*1+[1]*11   8 1   1344 6e18"
    "  768  4104  528 12 [0]*1+[1]*11   8 1   2178 6e18"
    "  512  2736  352 12 [0]*1+[1]*11   8 1   4165 6e18"
    " 1024  5472  704 15 [0]*1+[1]*14   4 1   1137 6e18"
    " 2048 10944 1408 15 [0]*1+[1]*14   4 8    325 6e18"
    " 1536  8208 1056 15 [0]*1+[1]*14   4 4    551 6e18"
    " 1536  8208 1056 18 [0]*1+[1]*17   4 4    472 6e18"
    " 1024  5472  704 18 [0]*1+[1]*17   4 1    986 6e18"
    " 2048 10944 1408 18 [0]*1+[1]*17   4 8    276 6e18"
    "  256  1368  176  6  [0]*1+[1]*5  32 1  23767 1e19"
    "  768  4104  528  6  [0]*1+[1]*5  16 1   5429 1e19"
    "  512  2736  352  6  [0]*1+[1]*5  32 1   9664 1e19"
    "  512  2736  352  9  [0]*1+[1]*8  16 1   8080 1e19"
    "  256  1368  176  9  [0]*1+[1]*8  32 1  21210 1e19"
    "  768  4104  528  9  [0]*1+[1]*8   8 1   4351 1e19"
    " 1536  8208 1056 12 [0]*1+[1]*11   4 1   1102 1e19"
    " 1024  5472  704 12 [0]*1+[1]*11   8 1   2240 1e19"
    "  768  4104  528 12 [0]*1+[1]*11   8 1   3630 1e19"
    "  512  2736  352 12 [0]*1+[1]*11   8 1   6942 1e19"
    " 1024  5472  704 15 [0]*1+[1]*14   4 1   1895 1e19"
    " 2048 10944 1408 15 [0]*1+[1]*14   4 8    541 1e19"
    " 1536  8208 1056 15 [0]*1+[1]*14   4 4    918 1e19"
    " 1536  8208 1056 18 [0]*1+[1]*17   4 4    786 1e19"
    " 1024  5472  704 18 [0]*1+[1]*17   4 1   1643 1e19"
    " 2048 10944 1408 18 [0]*1+[1]*17   4 8    460 1e19"
    "  256  1368  176  6  [0]*1+[1]*5  32 1  71300 3e19"
    "  768  4104  528  6  [0]*1+[1]*5  16 1  16286 3e19"
    "  512  2736  352  6  [0]*1+[1]*5  32 1  28992 3e19"
    "  512  2736  352  9  [0]*1+[1]*8  16 1  24239 3e19"
    "  256  1368  176  9  [0]*1+[1]*8  32 1  63628 3e19"
    "  768  4104  528  9  [0]*1+[1]*8   8 1  13052 3e19"
    " 1536  8208 1056 12 [0]*1+[1]*11   4 1   3306 3e19"
    " 1024  5472  704 12 [0]*1+[1]*11   8 1   6718 3e19"
    "  768  4104  528 12 [0]*1+[1]*11   8 1  10889 3e19"
    "  512  2736  352 12 [0]*1+[1]*11   8 1  20825 3e19"
    " 1024  5472  704 15 [0]*1+[1]*14   4 1   5685 3e19"
    " 2048 10944 1408 15 [0]*1+[1]*14   4 8   1621 3e19"
    " 1536  8208 1056 15 [0]*1+[1]*14   4 4   2752 3e19"
    " 1536  8208 1056 18 [0]*1+[1]*17   4 4   2358 3e19"
    " 1024  5472  704 18 [0]*1+[1]*17   4 1   4928 3e19"
    " 2048 10944 1408 18 [0]*1+[1]*17   4 8   1379 3e19"
)

i=0
for config in "${configs[@]}"; do
  read -r hidden_size ffn_hidden_size moe_ffn_hidden_size num_layers moe_layer_freq micro_batch_size pipeline_model_parallel_size train_iters flops <<< "$config"
    if [[ $SLURM_ARRAY_TASK_ID -eq $i ]]; then
        export HIDDEN_SIZE=$hidden_size
        export FFN_HIDDEN_SIZE=$ffn_hidden_size
        export MOE_FFN_HIDDEN_SIZE=$moe_ffn_hidden_size
        export NUM_LAYERS=$num_layers
        export MOE_LAYER_FREQ=$moe_layer_freq
        export MICRO_BATCH_SIZE=$micro_batch_size
        export PIPELINE_MODEL_PARALLEL_SIZE=$pipeline_model_parallel_size
        export TRAIN_ITERS=$train_iters
        export WANDB_RUN_GROUP="flame-moe-ablation-$flops"
        export WANDB_NAME="$SLURM_JOB_ID"
        export TRAIN_DATASET="$GCP_DATASET/dclm-138b/tokenized/EleutherAI/pythia-12b"
        bash scripts/training/flame-moe.sh
    fi
    ((i++))
done
