# Dataset

## Download

### DCLM-28B

```bash
sbatch scripts/dataset/download.sh dclm28b
```

## Tokenize

### DCLM-28B, GPT2 Tokenizer

```bash
LOAD_PATH=dataset/dclm28b/
TOKENIZER=openai-community/gpt2
SAVE_PATH=dataset/dclm28b-tokenized/$TOKENIZER/
sbatch scripts/dataset/tokenize.sh $LOAD_PATH $TOKENIZER $SAVE_PATH
```

### DCLM-28B, DeepSeek-V2-Lite Tokenizer

```bash
LOAD_PATH=dataset/dclm28b/
TOKENIZER=deepseek-ai/DeepSeek-V2-Lite
SAVE_PATH=dataset/dclm28b-tokenized/$TOKENIZER/
sbatch scripts/dataset/tokenize.sh $LOAD_PATH $TOKENIZER $SAVE_PATH
```

## Tokenize, Synthetic Dataset

### Mixtral-Textbook DCLM-28B, GPT2 Tokenizer

```bash
LOAD_PATH=dataset/dclm28b-textbook/mistralai/Mistral-7B-Instruct-v0.2/
TOKENIZER=openai-community/gpt2
SAVE_PATH=dataset/dclm28b-textbook-tokenized/mistralai/Mistral-7B-Instruct-v0.2/$TOKENIZER/
sbatch scripts/dataset/tokenize.sh $LOAD_PATH $TOKENIZER $SAVE_PATH
```
