import torch
import pickle
import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed
from matplotlib.colors import LinearSegmentedColormap

###
# Parameters
###

model_scale = "flame-moe-1.7b"
layer_nums = ["2", "6", "12", "18"]

K = 16
num_experts = 64

ckpt_step = "11029"
mount = "/tmp/slurm-31207"

###
# Utility to compute and save co-activation
###

def worker(file: Path):
    probs = torch.load(file, map_location="cpu")
    _, expert_ids = probs.nonzero(as_tuple=True)
    data = expert_ids.view(probs.shape[0], 6)
    maps = [[0 for _ in range(num_experts)] for _ in range(num_experts)]
    for rows in data:
        for i in rows:
            for j in rows:
                maps[i][j] += 1
                maps[j][i] += 1
    return maps

def compute_and_save(layer_num):
    workspace = Path(mount, "actives", ckpt_step, layer_num)
    output_file = Path(f"results/expert-coactivation/{model_scale}/{ckpt_step}/{layer_num}.pkl")
    output_file.parent.mkdir(parents=True, exist_ok=True)

    if output_file.exists():
        return  # Already computed

    record = [[0.0 for _ in range(num_experts)] for _ in range(num_experts)]


    files = list(workspace.glob("*.pt"))
    if not files:
        raise RuntimeError(f"No data found in {workspace}")

    with ProcessPoolExecutor(max_workers=64) as executor:
        futures = [executor.submit(worker, file) for file in files]
        for future in tqdm(as_completed(futures), total=len(futures), desc=f"Processing Layer {layer_num}", ncols=80):
            result = future.result()
            for i in range(num_experts):
                for j in range(num_experts):
                    record[i][j] += result[i][j]

    # Normalize
    for i in range(num_experts):
        base = record[i][i] if record[i][i] != 0 else 1
        for j in range(num_experts):
            record[i][j] /= base
        record[i][i] = 0

    # Save
    with output_file.open('wb') as f:
        pickle.dump(record, f)

###
# Ensure all layer records exist
###

for layer_num in layer_nums:
    compute_and_save(layer_num)

###
# Load and prepare data for plotting
###

filtered_records = []
global_min, global_max = float('inf'), float('-inf')

for layer_num in layer_nums:
    file = Path(f"results/expert-coactivation/{model_scale}/{ckpt_step}/{layer_num}.pkl")
    with file.open('rb') as f:
        record = pickle.load(f)

    record = np.array(record)
    expert_max = record.max(axis=1)
    top_expert_indices = np.argsort(expert_max)[-K:][::-1]
    filtered_record = record[top_expert_indices][:, top_expert_indices]

    filtered_records.append((filtered_record, top_expert_indices))
    global_min = min(global_min, filtered_record.min())
    global_max = max(global_max, filtered_record.max())

###
# Plotting
###

fig, axs = plt.subplots(1, len(layer_nums), figsize=(6 * len(layer_nums), 6))

if len(layer_nums) == 1:
    axs = [axs]

cmap = LinearSegmentedColormap.from_list("white_to_tartan", ["white", "#FDB515"])

for ax, (filtered_record, top_expert_indices), layer_num in zip(axs, filtered_records, layer_nums):
    X, Y = np.meshgrid(np.arange(K + 1), np.arange(K + 1))

    heatmap = ax.pcolormesh(X, Y, filtered_record, cmap=cmap, shading='auto', vmin=global_min, vmax=global_max)
    ax.invert_yaxis()
    ax.set_aspect("equal")

    ax.set_xticks(np.arange(K) + 0.5)
    ax.set_yticks(np.arange(K) + 0.5)
    ax.set_xticklabels(top_expert_indices, fontsize=10)
    ax.set_yticklabels(top_expert_indices, fontsize=10)

    ax.tick_params(axis='both', which='both', length=0)
    for spine in ax.spines.values():
        spine.set_visible(False)

    ax.set_title(f"Layer {layer_num}")

fig.colorbar(heatmap, ax=axs, shrink=0.7, pad=0.02)

layer_str = "-".join(layer_nums)
out_file = Path(f"figures/expert-coactivation/{model_scale}/{ckpt_step}/{layer_str}.pdf")
out_file.parent.mkdir(parents=True, exist_ok=True)

plt.savefig(out_file, bbox_inches='tight', pad_inches=0.01)
