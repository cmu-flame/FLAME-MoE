# Dataset

## Download

**DCLM-28B, original.**

```bash
export DATASET=dclm28b
sbatch scripts/dataset/download.sh
```

## Tokenize

**DCLM-28B, original.**

```bash
export DATASET=dclm28b
export TOKENIZER=openai-community/gpt2
sbatch scripts/dataset/tokenize.sh
```

```bash
export DATASET=dclm28b
export TOKENIZER=deepseek-ai/DeepSeek-V2-Lite
sbatch scripts/dataset/tokenize.sh
```

**DCLM-28B, transformed into academic, textbook style by Mistral-7B.**

```bash
export DATASET=dclm28b-textbook/mistralai/Mistral-7B-Instruct-v0.2
export TOKENIZER=openai-community/gpt2
sbatch scripts/dataset/tokenize.sh
```
