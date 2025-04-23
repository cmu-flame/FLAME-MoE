#!/bin/bash

gcloud storage rsync --recursive $TRAIN_DATASET $SSD_DATASET
