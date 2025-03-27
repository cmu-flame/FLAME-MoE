# Training

## dense-182m

**DCLM-28B, original.**

```bash
TOKENIZER=openai-community/gpt2
DATASET_PATH=dataset/dclm28b-tokenized/$TOKENIZER/
WEIGHTS_PATH=weights/dense-182m/
sbatch scripts/training/dense-182m.sh $TOKENIZER $DATASET_PATH $WEIGHTS_PATH
```

**DCLM-28B, transformed into academic, textbook style by Mistral-7B.**

```bash
TOKENIZER=openai-community/gpt2
DATASET_PATH=dataset/dclm28b-textbook-tokenized/mistralai/Mistral-7B-Instruct-v0.2/$TOKENIZER/
WEIGHTS_PATH=weights/dense-182m/
sbatch scripts/training/dense-182m.sh $TOKENIZER $DATASET_PATH $WEIGHTS_PATH
```
