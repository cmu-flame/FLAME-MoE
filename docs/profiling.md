# Profiling

### Step 1: Set the Parameters

Before dispatching the profiling job, configure the following environment variables in your shell:

#### Dataset

The name of the dataset to use.

The dataset is expected to be stored in Google Cloud Storage under the path: `$GCP_DATASET_DIR/$DATASET/textfiles/`. Each file in this directory must be in `.jsonl` format, where each line is a JSON object containing a "text" field with the input string to be tokenized.

#### Tokenizer

The name of the tokenizer to use.

This must exactly match its listing on [Hugging Face](https://huggingface.co/models) (e.g., `deepseek-ai/DeepSeek-V3`), as it will be loaded using the Transformers library.

```bash
export DATASET=dclm28b
export TOKENIZER=deepseek-ai/DeepSeek-V3
```

To run a lightweight profiling job for faster iteration or debugging, you can limit the number of model layers:

```bash
export NUM_LAYERS=2
```

### Step 2: Dispatch the Job

Submit the profiling job with:

```bash
sbatch scripts/profiling/deepseek-v3.sh
```

This will launch a short training job with profiling enabled. The job configuration can be adjusted in the SLURM script if needed.

#### Output

All logs and profiling outputs are stored under: 

```
logs/<job_name>/<job_id>/
```

For example, GPU throughput metrics will appear in: 

```
logs/profile-deepseek-v3/22146/stdout.log
```
