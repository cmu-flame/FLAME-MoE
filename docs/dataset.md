# Dataset

## Tokenization

This section explains how to tokenize a dataset using a Hugging Face-compatible tokenizer. You can customize the environment variables below to match your needs.

### Step 1: Set the Parameters

Before running the tokenization script, export the following variables in your shell:

```bash
export DATASET=dclm28b
export TOKENIZER=deepseek-ai/DeepSeek-V3
```

#### Dataset

The name of the dataset to tokenize.

The dataset is expected to be stored in Google Cloud Storage under the path: `$GCP_DATASET_DIR/$DATASET/textfiles/`. Each file in this directory must be in `.jsonl` format, where each line is a JSON object containing a "text" field with the input string to be tokenized.

#### Tokenizer

The name of the tokenizer to use.

This must exactly match its listing on [Hugging Face](https://huggingface.co/models) (e.g., `deepseek-ai/DeepSeek-V3`), as it will be loaded using the Transformers library.

### Step 2: Dispatch the Job

Once the parameters are set, launch the tokenization process:

```bash
sbatch scripts/dataset/tokenize.sh
```

By default, the script uses the following SLURM configuration to parallelize this job:

```bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem=512G
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1
```

This setup launches 8 tasks across 2 nodes, with a maximum of 4 tasks per node. We limit to 4 tasks per node (i.e., 24 CPUs each) to reduce contention from concurrent disk I/O operations during tokenization. You can modify `scripts/dataset/tokenize.sh` if you need to adjust compute resources for your environment.

#### Output

The tokenized files will be saved to: `$GCP_DATASET_DIR/$DATASET/tokenized/$TOKENIZER/`. The output is in Megatron-LM format suitable for downstream training workflows.
