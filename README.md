# FLAME-MoE

**FLAME-MoE** is a transparent, end-to-end research platform for Mixture-of-Experts (MoE) language models. It is designed to facilitate scalable training, evaluation, and experimentation with MoE architectures.

## 🔗 Model Checkpoints

Explore our publicly released checkpoints on Hugging Face:

* [FLAME-MoE-1.7B-10.3B](https://huggingface.co/CMU-FLAME/FLAME-MoE-1.7B-10.3B)
* [FLAME-MoE-721M-3.8B](https://huggingface.co/CMU-FLAME/FLAME-MoE-721M-3.8B)
* [FLAME-MoE-419M-2.2B](https://huggingface.co/CMU-FLAME/FLAME-MoE-419M-2.2B)
* [FLAME-MoE-290M-1.3B](https://huggingface.co/CMU-FLAME/FLAME-MoE-290M-1.3B)
* [FLAME-MoE-115M-459M](https://huggingface.co/CMU-FLAME/FLAME-MoE-115M-459M)
* [FLAME-MoE-98M-349M](https://huggingface.co/CMU-FLAME/FLAME-MoE-98M-349M)
* [FLAME-MoE-38M-100M](https://huggingface.co/CMU-FLAME/FLAME-MoE-38M-100M)

---

## 🚀 Getting Started

### 1. Clone the Repository

Ensure you clone the repository **recursively** to include all submodules:

```bash
git clone --recursive https://github.com/cmu-flame/MoE-Research
cd MoE-Research
```

### 2. Set Up the Environment

Set up the Conda environment using the provided script:

```bash
sbatch scripts/miscellaneous/install.sh
```

> **Note:** This assumes you're using a SLURM-managed cluster. Adapt accordingly if running locally.

---

## 📚 Data Preparation

### 3. Download and Tokenize the Dataset

Use the following SLURM jobs to download and tokenize the dataset:

```bash
sbatch scripts/dataset/download.sh
sbatch scripts/dataset/tokenize.sh
```

---

## 🧠 Training

### 4. Train FLAME-MoE Models

Launch training jobs for the desired model configurations:

```bash
bash scripts/release/flame-moe-1.7b.sh
bash scripts/release/flame-moe-721m.sh
bash scripts/release/flame-moe-290m.sh
```

---

## 📈 Evaluation

### 5. Evaluate the Model

Replace `...` with your training job ID:

```bash
export JOBID=...
sbatch scripts/evaluate.sh
```
