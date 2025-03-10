export WORKSPACE=$PWD
export DATASET_DIR=$WORKSPACE/dataset
export WEIGHTS_DIR=$WORKSPACE/weights
mkdir -p $DATASET_DIR $WEIGHTS_DIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate MoE
