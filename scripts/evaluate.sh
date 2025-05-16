#!/bin/bash

#SBATCH --job-name=evaluate
#SBATCH --output=logs/evaluate-%j.log
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=32
#SBATCH --mem=256G
#SBATCH --time=2-00:00:00

source scripts/config.sh
source scripts/secret.sh

trap "rm -rf $NFS_MOUNT $SSD_MOUNT" EXIT

export OMP_NUM_THREADS=8
export CUDA_DEVICE_MAX_CONNECTIONS=1
export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
export HF_DATASETS_TRUST_REMOTE_CODE=true

mkdir -p $SSD_WEIGHTS
gcloud storage cp -r $GCP_WEIGHTS/flame-moe/$JOBID/* $SSD_WEIGHTS/
mkdir -p logs/evaluate/$JOBID

echo $ITER > $SSD_WEIGHTS/latest_checkpointed_iteration.txt

cd lm-evaluation-harness

num_fewshots=(0 10)
fewshot_tasks=(
    "openbookqa,winogrande"
    "piqa,arc_easy,arc_challenge,hellaswag"
)

# for each fewshot task and corresponding num_fewshot, run the evaluation
for i in "${!num_fewshots[@]}"; do
    echo "Evaluating ${num_fewshots[$i]} shot for ${fewshot_tasks[$i]}"
    CKPT=$ITER PYTHONPATH=$PWD/../Megatron-LM CUDA_VISIBLE_DEVICES=$i torchrun --nproc_per_node=1 --master_port $((12345 + i)) -m lm_eval \
    ${MODEL_ARGS[@]} \
    --bf16 \
    --seq-length 2048 \
    --micro-batch-size 32 \
    --num_fewshot ${num_fewshots[$i]} \
    --batch_size 16 \
    --max-tokens-to-oom 10000000 \
    --seed 42 \
    --load $SSD_WEIGHTS \
    --model megatron_lm \
    --tasks "${fewshot_tasks[$i]}" \
    --output_path ../results/flame-moe/$JOBID > ../logs/evaluate/$JOBID/${num_fewshots[$i]}shot-${i}.log 2>&1 &
done
