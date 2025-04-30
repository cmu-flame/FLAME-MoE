#!/bin/bash
# Download the dataset.

i=1; host=$(hostname)
mkdir -p $SSD_DATASET

until gsutil -m rsync -r $TRAIN_DATASET $SSD_DATASET; do
    echo "[$host] Retry attempt $i"
    delay=$((2**i))
    [ $delay -gt 32 ] && delay=32
    sleep $delay
    i=$((i + 1))
done
