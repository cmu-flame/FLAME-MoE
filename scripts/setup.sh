#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --job-name=setup
#SBATCH --output=logs/%x.log
#SBATCH --partition=preempt

#SBATCH --mem=128G
#SBATCH --cpus-per-task=32
#SBATCH --gres=gpu:1

source ~/miniconda3/etc/profile.d/conda.sh

conda create -n MoE python=3.10 -y
conda activate MoE

pip install -r Megatron-LM/requirements/pytorch_24.10/requirements.txt

pushd apex
pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
popd

pushd TransformerEngine
export CPLUS_INCLUDE_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/nvtx/include:$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn/include
export C_INCLUDE_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/nvtx/include:$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn/include
export CUDNN_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn
export NVTE_FRAMEWORK=pytorch
export MAX_JOBS=32
pip install .
popd

pushd lm-evaluation-harness
pip install -e .
popd

pip install transformers pybind11 tensorboard
