#!/bin/bash
# Invoked by scripts/dataset/download.sh

# Author: Hao Kang
# Date: March 26, 2025

# This script processes task files containing S3 links and performs the following operations:
# 1. Reads the S3 link from the task file.
# 2. Downloads the file from S3 with up to 3 retries.
# 3. Extracts the downloaded .zstd file, retrying up to 3 times.
# 4. Uploads the extracted file to a Google Cloud Storage (GCS) bucket with up to 3 retries.
# 5. Marks the task as completed by clearing the task file.

# Parameters:
# - $1: Path to the task file containing the S3 link.

# Environment Variables:
# - DISKSPACE: Local directory for downloads and extraction.
# - GCPBUCKET: Destination Google Cloud Storage bucket.

# Return Codes:
# - 0: Success (all operations completed).
# - 1: Failure (download, extraction, or upload fails after 3 attempts).

download() {
    task=$1
    link=$(sed -n '1p' $task)  # Read first line (S3 link)
    file=$DISKSPACE/$(basename $task .task)  # Determine local file path

    # Skip empty task files (already processed)
    if [ -z "$link" ]; then
        return 0
    fi

    # Download file from S3 with up to 3 attempts
    flag=0
    for i in {1..3}; do
        echo "Downloading $link (Attempt $i of 3)"
        aws s3 cp $link $file > /dev/null 2>&1 && flag=1 && break
        echo "Failed to download $link, retrying..." && sleep 5
    done

    # Exit if download failed
    if [ $flag -eq 0 ]; then
        echo "ERROR: Failed to download $link after 3 attempts." >&2
        return 1
    fi

    # Extract the .zstd file with up to 3 attempts
    flag=0
    for i in {1..3}; do
        echo "Extracting $file (Attempt $i of 3)"
        unzstd $file > /dev/null 2>&1 && rm -f $1 && flag=1 && break
        echo "Failed to extract $file, retrying..." && sleep 5
    done

    # Exit if extraction failed
    if [ $flag -eq 0 ]; then
        echo "ERROR: Failed to extract $file after 3 attempts." >&2
        return 1
    fi
    file=${file%.zstd}  # Update file name to extracted version

    # Upload extracted file to GCS with up to 3 attempts
    flag=0
    for i in {1..3}; do
        echo "Uploading $file (Attempt $i of 3)"
        gcloud storage cp $file $GCPBUCKET/dataset/dclm28b/ > /dev/null 2>&1 && flag=1 && break
        echo "Failed to upload $file, retrying..." && sleep 5
    done

    # Exit if upload failed
    if [ $flag -eq 0 ]; then
        echo "ERROR: Failed to upload $file after 3 attempts." >&2
        return 1
    fi

    # Mark task as completed
    echo "" > $task
}

# Export function for use in subshells
export -f download

# Process all ".task" files in the workspace directory
find $WORKSPACE -type f -name "*.task" | while read -r line; do
    # Use flock to prevent multiple processes from working on the same file simultaneously
    flock -n $line -c "download $line" || true
done
