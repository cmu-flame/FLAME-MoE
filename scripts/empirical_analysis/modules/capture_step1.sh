#!/bin/bash

mkdir -p $SSD_WEIGHTS
gcloud storage rsync --recursive $TRAIN_WEIGHTS $SSD_WEIGHTS

mkdir -p $SSD_DATASET
gcloud storage rsync --recursive $TRAIN_DATASET $SSD_DATASET
