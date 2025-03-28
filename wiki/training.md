# Training

## Dense-182M

```bash
export JID=0328
export DATASET=dclm28b
export TOKENIZER=openai-community/gpt2
sbatch scripts/training/dense-182m.sh
```

## MoE-182M-1.4B

```bash
export JID=0328
export DATASET=dclm28b
export TOKENIZER=openai-community/gpt2
sbatch scripts/training/moe-182m-1.4b.sh
```

## Dense-1.4B

```bash
export JID=0328
export DATASET=dclm28b
export TOKENIZER=openai-community/gpt2
sbatch scripts/training/dense-1.4b.sh
```
