#!/bin/bash
# Setup the Docker container to run the specified script.

# Author: Hao Kang <haok@andrew.cmu.edu>
# Date: March 7, 2025

set -e # Exit on error

# Ensure a script argument is provided.
if [ -z "$1" ]; then
    echo "Error: No script specified."
    echo "Usage: $0 <script_name> [extra_arguments...]"
    exit 1
fi

# Capture the script name and retain the arguments.
SCRIPT_NAME=$1
shift

# Pull the NVIDIA container image for PyTorch.
IMAGE=nvcr.io/nvidia/pytorch:24.10-py3
docker pull $IMAGE

# Save SLURM environment variables to a temporary file.
SLURM_ENV_FILE=$(mktemp -p $TEMP_DIR)
trap 'rm -f "$SLURM_ENV_FILE"' EXIT
env | grep '^SLURM' >$SLURM_ENV_FILE

# Export necessary environments.
EXPORT_ENVS=(
    --env-file="$SLURM_ENV_FILE"
    --env DATASET_DIR=$DATASET_DIR
    --env WEIGHTS_DIR=$WEIGHTS_DIR
    --env LOGS_DIR=$LOGS_DIR
    --env TEMP_DIR=$TEMP_DIR
)

# Define Docker arguments.
DOCKER_ARGS=(
    --rm                                   # Remove container on exit
    --network host                         # Use host network
    --gpus device="$SLURM_STEP_GPUS"       # Assign SLURM GPUs
    --ipc=host                             # Share host IPC namespace
    --ulimit memlock=-1:-1                 # Unlock all memory
    --ulimit stack=67108864                # Set 64MB stack limit
    --user "$SLURM_JOB_UID:$SLURM_JOB_GID" # Run as current user
)

# Define volume mounts.
VOLUME_ARGS=(
    -v "$DATASET_DIR:$DATASET_DIR"
    -v "$WEIGHTS_DIR:$WEIGHTS_DIR"
    -v "$LOGS_DIR:$LOGS_DIR"
    -v "$TEMP_DIR:$TEMP_DIR"
    -v "$(pwd)/Megatron-LM:/workspace/Megatron-LM"
    -v "$(pwd)/scripts:/workspace/scripts"
)

# Run the Docker container and execute the specified script with any extra arguments passed.
docker run "${DOCKER_ARGS[@]}" "${VOLUME_ARGS[@]}" "${EXPORT_ENVS[@]}" "$IMAGE" \
    bash -c "/workspace/$SCRIPT_NAME $*"
