#!/bin/bash
# Invoked by scripts/dataset/tokenize/dclm-28B-olmoe.sh

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

retry() {
    for i in {1..3}; do
        echo "Tokenizing $1 (Attempt $i of 3)"
        python tools/preprocess_data.py \
            --input $1 \
            --output-prefix $DATASET_DIR/dclm-28B-olmoe/$(basename $1 .jsonl) \
            --tokenizer-type HuggingFaceTokenizer \
            --tokenizer-model allenai/OLMoE-1B-7B-0924 \
            --append-eod \
            --workers 32 > /dev/null 2>&1 && break
        echo "Failed to tokenize $1, retrying..." && sleep 5
    done
}

cd $WORKSPACE/Megatron-LM
split $TASK_INDEX -n l/$((SLURM_PROCID + 1))/$SLURM_NTASKS | while read -r line; do
    retry $line
done
