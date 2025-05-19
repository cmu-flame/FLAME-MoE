#!/bin/bash

mkdir -p $SSD_MOUNT/actives
gcloud storage ls --recursive $GCP_MOUNT/actives/$TRAIN_JOB_NAME/$TRAIN_JOB_ID/ | grep -v '^$' | grep -v ':$' | awk '{print $NF}' | xargs -P 128 -I {} bash -c '
        dest="$SSD_MOUNT/actives/$(echo {} | sed "s|$GCP_MOUNT/actives/$TRAIN_JOB_NAME/$TRAIN_JOB_ID/||")"
        mkdir -p "$(dirname "$dest")"
        until gcloud storage cp --no-user-output-enabled "{}" "$dest"; do continue; done
    '
