#!/bin/bash

mkdir -p $SSD_DATASET $SSD_WEIGHTS
gsutil -o "GSUtil:sliced_object_download_max_components=0" -m rsync -r $TRAIN_DATASET $SSD_DATASET
