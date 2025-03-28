#!/bin/bash
# Download the dataset and mount the weights for training.

if [ $SLURM_LOCALID -eq 0 ]; then
    gcloud storage rsync --recursive \
        gs://$TEAM_BUCKET/$DATASET_GCP/$DATASET/tokenized/$TOKENIZER/ $DATASET_PATH
fi

if [ $SLURM_LOCALID -eq 0 ]; then
    gcsfuse --only-dir $WEIGHTS_GCP/dense-182m/$RUNID $TEAM_BUCKET $WEIGHTS_PATH
fi
