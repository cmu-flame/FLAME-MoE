# Dataset

## Download

...

## Tokenize

### DCLM-28B

**GPT2 Tokenizer**

```bash
source devconfig.sh
LOAD_DIR=$DATASET_DIR/dclm-28B
TOKENIZER_MODEL=openai-community/gpt2
SAVE_DIR=$DATASET_DIR/dclm-28B-tokenized/$TOKENIZER_MODEL
sbatch scripts/dataset/tokenize.sh $LOAD_DIR $TOKENIZER_MODEL $SAVE_DIR
```

### Synthetic Textbook via Mixtral-7B on DCLM-28B

**GPT2 Tokenizer**

```bash
source devconfig.sh
LOAD_DIR=$DATASET_DIR/dclm-28B-textbook/mistralai/Mistral-7B-Instruct-v0.2
TOKENIZER_MODEL=openai-community/gpt2
SAVE_DIR=$DATASET_DIR/dclm-28B-textbook-tokenized/mistralai/Mistral-7B-Instruct-v0.2/$TOKENIZER_MODEL
sbatch scripts/dataset/tokenize.sh $LOAD_DIR $TOKENIZER_MODEL $SAVE_DIR
```
