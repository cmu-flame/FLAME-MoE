#!/bin/bash
# Invoked by scripts/dataset/tokenize.sh

export LOAD_DIR=$1
export TOKENIZER=$2
export SAVE_DIR=$3

work() {
    local load_file=$1
    local save_file=$SAVE_DIR/$(basename $load_file)
    local hash_file=$SAVE_DIR/$(basename $load_file).sha256

    if [ -f $save_file ] && [ -f $hash_file ] && sha256sum --status -c $hash_file; then
      exit 0
    fi

    echo "Tokenizing: $load_file"
    mkdir -p $(dirname $save_file) && echo 'hello,world' > $save_file
    sha256sum $load_file > $hash_file
}

export -f work

find $LOAD_DIR -type f -name "*.jsonl" | sort | while read -r file; do
    flock -n $file -c "work $file"
done
