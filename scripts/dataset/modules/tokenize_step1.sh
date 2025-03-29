#!/bin/bash
# Download and tokenize the dataset from GCS, then upload to GCS.
# Invoked by scripts/dataset/tokenize.sh

# Author: Hao Kang
# Date: March 9, 2025

tokenize() {
    task=$1

    # Skip if task file is empty (already processed)
    [ ! -s "$task" ] && return 0

    # Read GCS link and local file path
    link=$(sed -n '1p' $task)
    file=$(sed -n '2p' $task)

    # Download from GCS (max 3 attempts)
    for i in {1..3}; do
        echo "Downloading $link (Attempt $i of 3)"
        gcloud storage cp $link $file > /dev/null 2>&1 && break
        echo "Failed to download $link, retrying..." && sleep 5
        if [ $i -eq 3 ]; then
            echo "ERROR: Failed to download $link after 3 attempts." >&2
            return 1
        fi
    done

    # Tokenize the file with Megatron-LM (max 3 attempts)
    cd Megatron-LM
    for i in {1..3}; do
        echo "Tokenizing $file (Attempt $i of 3)"
        python tools/preprocess_data.py \
            --input $file \
            --output-prefix ${file%.jsonl} \
            --tokenizer-type HuggingFaceTokenizer \
            --tokenizer-model $TOKENIZER \
            --append-eod \
            --workers $SLURM_CPUS_PER_TASK > /dev/null 2>&1 && break
        echo "Failed to tokenize $file, retrying..." && sleep 5
        if [ $i -eq 3 ]; then
            echo "ERROR: Failed to tokenize $file after 3 attempts." >&2
            return 1
        fi
    done

    # Upload the tokenized files to GCS (max 3 attempts)
    for i in {1..3}; do
        echo "Uploading tokenized files to GCS (Attempt $i of 3)"
        gcloud storage cp \
            ${file%.jsonl}_text_document.bin \
            ${file%.jsonl}_text_document.idx \
            $GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/ > /dev/null 2>&1 && break
        echo "Failed to upload tokenized files, retrying..." && sleep 5
        if [ $i -eq 3 ]; then
            echo "ERROR: Failed to upload tokenized files after 3 attempts." >&2
            return 1
        fi
    done

    # Mark task as completed
    > $task
}

export -f tokenize

# Process task files with file locking to avoid conflicts
find $NFS_MOUNT -type f -name "*.task" | while read -r line; do
    flock -n $line -c "tokenize $line" || true
done
