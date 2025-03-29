# Evaluation

## Dense-182M

```bash
export STEP=10k
export MODEL=dense-182m
sbatch scripts/evaluate.sh
```

## MoE-182M-1.4B

```bash
export STEP=10k
export MODEL=moe-182m-1.4b
sbatch scripts/evaluate.sh
```

## Dense-1.4B

```bash
export STEP=10k
export MODEL=dense-1.4b
sbatch scripts/evaluate.sh
```

## DeepSeek-V2-Lite

```bash
export STEP=80k
export MODEL=deepseek-v2-lite
sbatch scripts/evaluate.sh
```
