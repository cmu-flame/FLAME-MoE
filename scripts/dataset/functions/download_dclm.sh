#!/bin/bash
# Download and extract the DCLM dataset from S3, then upload to GCS.
# Invoked by scripts/dataset/download.sh

# Author: Hao Kang
# Date: March 26, 2025

download() {
    task=$1

    # Skip if task file is empty (already processed)
    [ ! -s "$task" ] && return 0

    # Read S3 link and local file path
    link=$(sed -n '1p' $task)
    file=$(sed -n '2p' $task)

    # Download from S3 (max 3 attempts)
    for i in {1..3}; do
        echo "Downloading $link (Attempt $i of 3)"
        aws s3 cp $link $file > /dev/null 2>&1 && break
        echo "Failed to download $link, retrying..." && sleep 5
    done || { echo "ERROR: Failed to download $link after 3 attempts." >&2; return 1; }

    # Extract .zstd file (max 3 attempts)
    for i in {1..3}; do
        echo "Extracting $file (Attempt $i of 3)"
        unzstd $file > /dev/null 2>&1 && rm -f $file && break
        echo "Failed to extract $file, retrying..." && sleep 5
    done || { echo "ERROR: Failed to extract $file after 3 attempts." >&2; return 1; }

    # Upload extracted file to GCS (max 3 attempts)
    file=${file%.zstd}
    for i in {1..3}; do
        echo "Uploading $file (Attempt $i of 3)"
        gcloud storage cp $file $GCPBUCKET/dataset/dclm28b/ > /dev/null 2>&1 && break
        echo "Failed to upload $file, retrying..." && sleep 5
    done || { echo "ERROR: Failed to upload $file after 3 attempts." >&2; return 1; }

    # Mark task as completed
    > $task
}

export -f download

# Process task files with file locking to avoid conflicts
find $WORKSPACE -type f -name "*.task" | while read -r line; do
    flock -n $line -c "download $line" || true
done
