import stat
import pandas as pd
from pathlib import Path

script = r"""
#!/bin/bash

#SBATCH --job-name=search
#SBATCH --output=logs/%x/%A/%j/stdout.log

#SBATCH --partition=flame
#SBATCH --time=07-00:00:00
#SBATCH --qos=flame-t1b_g1_qos
#SBATCH --array=0-{length}%8

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1536G
#SBATCH --cpus-per-task=208
#SBATCH --gres=gpu:8

source scripts/config.sh
source scripts/secret.sh

configs=({configs})

i=0
for config in "${{configs[@]}}"; do
  read -r hidden_size ffn_hidden_size moe_ffn_hidden_size num_layers moe_layer_freq micro_batch_size expert_model_parallel_size train_iters flops <<< "$config"
    if [[ $SLURM_ARRAY_TASK_ID -eq $i ]]; then
        export HIDDEN_SIZE=$hidden_size
        export FFN_HIDDEN_SIZE=$ffn_hidden_size
        export MOE_FFN_HIDDEN_SIZE=$moe_ffn_hidden_size
        export NUM_LAYERS=$num_layers
        export MOE_LAYER_FREQ=$moe_layer_freq
        export MICRO_BATCH_SIZE=$micro_batch_size
        export EXPERT_MODEL_PARALLEL_SIZE=$expert_model_parallel_size
        export TRAIN_ITERS=$train_iters
        export WANDB_RUN_GROUP="ablation-$flops"
        export WANDB_NAME="$SLURM_JOB_ID"
        export TRAIN_DATASET="$GCP_DATASET/dclm-138b/tokenized/EleutherAI/pythia-12b"
        bash scripts/training/flame-moe.sh
    fi
    ((i++))
done
""".strip()

def main():
    df = pd.read_csv("https://docs.google.com/spreadsheets/d/1sIr9HRwYbUXKzlskUTMorMa2A_cAzDwE0eUJnk-W1dQ/export?format=csv&gid=1059339506")
    df = df.sort_values(by=["num_layers"])

    n, configs = 0, "\n"
    for c in df.columns:
        if c.startswith("train_iters_"):
            for _, row in df.iterrows():
                moe_layer_freq = f"[0]*1+[1]*{int(row['num_layers'])-1}"
                configs += '    " '
                configs += " ".join([
                    str(row["hidden_size"]).rjust(4),
                    str(row["ffn_hidden_size"]).rjust(5),
                    str(row["moe_ffn_hidden_size"]).rjust(4),
                    str(row["num_layers"]).rjust(2),
                    moe_layer_freq.rjust(12),
                    str(row["micro_batch_size"]).rjust(3),
                    str(row["expert_model_parallel_size"]).rjust(1),
                    str(row[c]).rjust(6),
                    c.removeprefix("train_iters_")
                ])
                configs += f'" # {n}\n'
                n += 1

    file = Path(f"scripts/ablation/search.sh")
    file.write_text(script.format(length=n - 1, configs=configs) + "\n")
    file.chmod(file.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

if __name__ == '__main__':
    main()
