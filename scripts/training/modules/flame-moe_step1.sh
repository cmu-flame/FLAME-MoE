#!/bin/bash

mkdir -p $SSD_DATASET
until gcloud storage cp --recursive $TRAIN_DATASET/ $SSD_DATASET/; do continue; done
