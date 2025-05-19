#!/bin/bash

mkdir -p $SSD_MOUNT/actives
gcloud storage cp --recursive $GCP_MOUNT/actives/$TRAIN_JOB_NAME/$TRAIN_JOB_ID/* $SSD_MOUNT/actives
