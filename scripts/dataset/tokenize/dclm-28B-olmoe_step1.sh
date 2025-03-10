#!/bin/bash
# Invoked by scripts/dataset/tokenize/dclm-28B-olmoe.sh

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

cd Megatron-LM
split $TASK_INDEX -n l/$((SLURM_PROCID + 1))/$SLURM_NTASKS | while read -r line; do
    echo "Tokenizing $line"
    python tools/preprocess_data.py \
        --input $line \
        --output-prefix $DATASET_DIR/dclm-28B-olmoe/$(basename $line .jsonl) \
        --tokenizer-type HuggingFaceTokenizer \
        --tokenizer-model allenai/OLMoE-1B-7B-0924 \
        --append-eod \
        --workers 32
done
