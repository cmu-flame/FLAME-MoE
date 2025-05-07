#!/bin/bash

gcloud storage cp --recursive $SSD_MOUNT/actives $GCP_MOUNT/actives/$TRAIN_JOB_NAME/$TRAIN_JOB_ID
