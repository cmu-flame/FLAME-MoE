#!/bin/bash
# Download the pretrained weights and dataset.

mkdir -p $SSD_WEIGHTS
gcloud storage ls --recursive $TRAIN_WEIGHTS/ \
  | grep -v '^$' | grep -v ':$' | awk '{print $NF}' \
  | xargs -P 24 -I {} bash -c '
    echo "[$(hostname)] Fetching {} ..."
    dest="$SSD_WEIGHTS/$(echo {} | sed "s|$TRAIN_WEIGHTS/||")"
    mkdir -p "$(dirname "$dest")"
    until gcloud storage cp --no-user-output-enabled "{}" "$dest"; do continue; done
  '

mkdir -p $SSD_DATASET
gcloud storage ls --recursive $TRAIN_DATASET/ \
  | grep -v '^$' | grep -v ':$' | awk '{print $NF}' \
  | xargs -P 48 -I {} bash -c '
    echo "[$(hostname)] Fetching {} ..."
    dest="$SSD_DATASET/$(echo {} | sed "s|$TRAIN_DATASET/||")"
    mkdir -p "$(dirname "$dest")"
    until gcloud storage cp --no-user-output-enabled "{}" "$dest"; do continue; done
  '
