# Training

## dense-182m

```bash
export JID=0328a
export DATASET=dclm28b
export TOKENIZER=openai-community/gpt2
sbatch scripts/training/dense-182m.sh
```

## dense-1.4b

```bash
export DATASET=dclm28b
export TOKENIZER=openai-community/gpt2
sbatch scripts/training/dense-1.4b.sh
```
