#!/bin/bash
# Invoked by scripts/dataset/tokenize.sh.

tokenize() {
    source devconfig.sh
    source devsecret.env

    local load_file=$1
    local base_stem=$(basename $load_file .jsonl)
    local save_stem=$SAVE_DIR/$base_stem
    local hash_file=$SAVE_DIR/$base_stem.sha256

    if [ -f $hash_file ] && sha256sum --status -c $hash_file; then
        echo "Skipping $load_file (already tokenized)"
        return
    fi

    cd Megatron-LM
    for i in {1..3}; do
        echo "Tokenizing $load_file (attempt $i of 3)"
        python tools/preprocess_data.py \
            --input $load_file \
            --output-prefix $save_stem \
            --tokenizer-type HuggingFaceTokenizer \
            --tokenizer-model $TOKENIZER \
            --append-eod \
            --workers $SLURM_CPUS_PER_TASK > /dev/null 2>&1 && break
        echo "Failed to tokenize $load_file, retrying..." && sleep 5
    done

    sha256sum $save_stem* > $hash_file
}

export LOAD_DIR=$1
export TOKENIZER=$2
export SAVE_DIR=$3
export -f tokenize
mkdir -p $SAVE_DIR

find $LOAD_DIR -type f -name "*.jsonl" | sort | while read -r file; do
    flock -n $file -c "tokenize $file"
done
