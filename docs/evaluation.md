# Evaluation

This section describes how to run evaluation jobs for any model using a SLURM script. We provide a working example using the `moe-182m-1.4b` model. You can modify the environment variables to evaluate other models as needed.

## Step 1: Set environment variables

Before launching the evaluation, export the following variables in your shell:

- `MODEL`: model architecture or name (e.g., `moe-182m-1.4b`).
- `TOKENIZER`: tokenizer associated with the model. This must match the one used during training.
- `JOBID`: SLURM job ID used during training. This identifies the location of the model checkpoint.
- `ITERS`: training step to evaluate. This selects the checkpoint saved at that iteration (e.g., `10000` means "evaluate the weights saved at step 10k").

For example:

```bash
export MODEL=moe-182m-1.4b
export TOKENIZER=openai-community/gpt2
export JOBID=20068
export ITERS=10000
```

You can substitute these values with those corresponding to your model and training run.

## Step 2: Submit the evaluation job

To launch evaluation, run:

```bash
sbatch scripts/evaluate.sh
```

This script should:

- Load the checkpoint associated with `JOBID` and `ITERS`.
- Initialize the model and tokenizer.
- Run evaluation.
- Write results to `logs/evaluate-${SLURM_JOB_ID}.log` by default.

## Notes

- The evaluation script must read the environment variables defined above.
- To evaluate model performance over time, run this process with different `ITERS` values (e.g., 10000, 20000, 30000).
