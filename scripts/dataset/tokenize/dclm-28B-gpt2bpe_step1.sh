#!/bin/bash
# Invoked by scripts/dataset/tokenize/dclm-28B-gpt2bpe.sh

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 9, 2025

cd Megatron-LM
split $TASK_INDEX -n l/$((SLURM_PROCID + 1))/$SLURM_NTASKS | while read -r line; do
    echo "Tokenizing $line"
    python tools/preprocess_data.py \
        --input $line \
        --output-prefix $DATASET_DIR/dclm-28B-gpt2bpe/$(basename $line .jsonl) \
        --tokenizer-type GPT2BPETokenizer \
        --vocab-file $DATASET_DIR/gpt2-vocab.json \
        --merge-file $DATASET_DIR/gpt2-merges.txt \
        --append-eod \
        --workers 32
done
