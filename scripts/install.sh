#!/bin/bash
# Install the runtime environment.

#SBATCH --job-name=install
#SBATCH --output=logs/%x/%j.log

#SBATCH --partition=flame
#SBATCH --qos=flame-t1b_g1_qos
#SBATCH --time=00-04:00:00

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

source ~/miniconda3/etc/profile.d/conda.sh

conda create -n MoE python=3.10 -y
conda activate MoE

pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124
pip install -r Megatron-LM/requirements/pytorch_24.10/requirements.txt
pip install transformers pybind11 tensorboard

pushd apex
pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
popd

pushd TransformerEngine
export CPLUS_INCLUDE_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/nvtx/include:$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn/include
export C_INCLUDE_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/nvtx/include:$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn/include
export CUDNN_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn
export NVTE_FRAMEWORK=pytorch
export MAX_JOBS=64
pip install .
popd
