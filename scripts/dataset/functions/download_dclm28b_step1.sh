#!/bin/bash
# Invoked by scripts/dataset/download_dclm28b.sh

# Author: Hao Kang
# Date: March 26, 2025

download() {
    task=$1
    link=$(sed -n '1p' $task)
    file=$DISKSPACE/$(basename $task .task)

    # If the task is empty (i.e. already completed), skip it
    if [ -z "$link" ]; then
        return 0
    fi

    # Download the file from S3
    flag=0
    for i in {1..3}; do
        echo "Downloading $link (Attempt $i of 3)"
        aws s3 cp $link $file > /dev/null 2>&1 && flag=1 && break
        echo "Failed to download $link, retrying..." && sleep 5
    done
    if [ $flag -eq 0 ]; then
        echo "ERROR: Failed to download $link after 3 attempts." >&2
        return 1
    fi

    # Extract the file
    flag=0
    for i in {1..3}; do
        echo "Extracting $file (Attempt $i of 3)"
        unzstd $file > /dev/null 2>&1 && rm -f $1 && flag=1 && break
        echo "Failed to extract $file, retrying..." && sleep 5
    done
    if [ $flag -eq 0 ]; then
        echo "ERROR: Failed to extract $file after 3 attempts." >&2
        return 1
    fi
    file=${file%.zstd}

    # Upload the file to GCS
    flag=0
    for i in {1..3}; do
        echo "Uploading $file (Attempt $i of 3)"
        gcloud storage cp $file $GCPBUCKET/dataset/dclm28b/ > /dev/null 2>&1 && flag=1 && break
        echo "Failed to upload $file, retrying..." && sleep 5
    done
    if [ $flag -eq 0 ]; then
        echo "ERROR: Failed to upload $file after 3 attempts." >&2
        return 1
    fi

    # Mark the task as completed
    echo "" > $task
}

export -f download

# Find all tasks in the workspace, lock each, and run the download function.
find $WORKSPACE -type f -name "*.task" | while read -r line; do
    flock -n $line -c "download $line" || true
done
