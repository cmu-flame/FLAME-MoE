# MoE Research

This repository provides research and training pipelines for Mixture of Experts (MoE) models. The MoE models enable efficient learning by leveraging a sparse selection of experts. Follow the instructions below to set up your environment, prepare datasets, train MoE models, and evaluate their performance.

## Quickstart Guide

### 0. Setup the Environment

**Clone the Repository**

Clone the repository recursively to include all submodules:

```bash
git clone --recursive https://github.com/cxcscmu/MoE-Research
cd MoE-Research
```

**Create and Activate the Conda Environment**

Ensure you have [Conda](https://www.anaconda.com/docs/getting-started/miniconda/install) installed, then run:

```bash
conda create -n MoE python=3.10
conda activate MoE
```

**Install Dependencies**

Install Megatron-LM:

```bash
pip install -r Megatron-LM/requirements/pytorch_24.10/requirements.txt
```

Install Apex with CUDA extensions:

```bash
pushd apex
pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
popd
```

Install Transformer Engine:

```bash
pushd TransformerEngine
export CPLUS_INCLUDE_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/nvtx/include:$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn/include
export C_INCLUDE_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/nvtx/include:$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn/include
export CUDNN_PATH=$CONDA_PREFIX/lib/python3.10/site-packages/nvidia/cudnn
export NVTE_FRAMEWORK=pytorch
export MAX_JOBS=32
pip install .
popd
```

Install Language Model Evaluation Harness:

```bash
pushd lm-evaluation-harness
pip install -e .
popd
```

Additional dependencies:

```bash
pip install transformers pybind11 tensorboard
```

**AWS CLI Requirement**

Make sure you have [AWS CLI](https://aws.amazon.com/cli/) installed, as the DCLM dataset is hosted on Amazon S3.

**API Key Setup**

Create a file named `devsecret.env` to store credentials like the following:

```
export WANDB_API_KEY=<wandb_api_key>
```

### 1. Prepare the Dataset

**DCLM-28B**

```bash
sbatch scripts/dataset/download/dclm-28B.sh
sbatch scripts/dataset/tokenize/dclm-28B-gpt2bpe.sh
sbatch scripts/dataset/tokenize/dclm-28B-olmoe.sh
```

### 2. Train the Model

**olmoe-1B-7B**

```bash
sbatch scripts/train/olmoe-1B-7B.sh
```

**llama-182M-1.4B**

```bash
sbatch scripts/train/llama-182M-1.4B.sh
```

### 3. Evaluate the Model

```bash
sbatch scripts/eval/eval.sh
```
