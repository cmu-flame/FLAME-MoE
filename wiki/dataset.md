# Dataset

## Download

**DCLM-28B, original.**

```bash
export DATASET=dclm28b
sbatch scripts/dataset/download.sh
```

## Tokenization

### GPT2 Tokenizer

**DCLM-28B, original.**

```bash
LOAD_PATH=dataset/dclm28b/
TOKENIZER=openai-community/gpt2
SAVE_PATH=dataset/dclm28b-tokenized/$TOKENIZER/
sbatch scripts/dataset/tokenize.sh $LOAD_PATH $TOKENIZER $SAVE_PATH
```

**DCLM-28B, transformed into academic, textbook style by Mistral-7B.**

```bash
LOAD_PATH=dataset/dclm28b-textbook/mistralai/Mistral-7B-Instruct-v0.2/
TOKENIZER=openai-community/gpt2
SAVE_PATH=dataset/dclm28b-textbook-tokenized/mistralai/Mistral-7B-Instruct-v0.2/$TOKENIZER/
sbatch scripts/dataset/tokenize.sh $LOAD_PATH $TOKENIZER $SAVE_PATH
```

### DeepSeek-V2-Lite Tokenizer

**DCLM-28B, original.**

```bash
LOAD_PATH=dataset/dclm28b/
TOKENIZER=deepseek-ai/DeepSeek-V2-Lite
SAVE_PATH=dataset/dclm28b-tokenized/$TOKENIZER/
sbatch scripts/dataset/tokenize.sh $LOAD_PATH $TOKENIZER $SAVE_PATH
```
