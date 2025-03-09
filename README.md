# MoE Research

## Quickstart

### 0. Setup the Environment

Clone the repository recursively to include all submodules:

```bash
git clone --recursive https://github.com/cxcscmu/MoE-Research
cd MoE-Research
```

Create and activate the conda environment:

```bash
conda create -n MoE python=3.10
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
```

### 1. Prepare the Dataset

**The Pile**

```bash
sbatch scripts/dataset/download/pile.sh
sbatch scripts/dataset/tokenize/pile-gpt2bpe.sh
```

**DCLM-28B**

```bash
sbatch scripts/dataset/download/dclm-28B.sh
sbatch scripts/dataset/tokenize/dclm-28B-gpt2bpe.sh
```
