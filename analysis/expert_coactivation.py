import torch
import pickle
import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed
from matplotlib.colors import LinearSegmentedColormap

###
# Define the task.
###

ckpt_step, layer_num, model_scale = "8815", "12", "flame-moe-721m"
workspace = Path("/tmp/slurm-31207/actives/", ckpt_step, layer_num)

###
# Do the gathering.
###

file = Path(f"results/expert-coactivation/{model_scale}/{ckpt_step}/{layer_num}.pkl")
file.parent.mkdir(parents=True, exist_ok=True)

def worker(file: Path):
    data = torch.load(file, map_location="cpu")
    assert data.shape == (16384, 6) # micro-batch tokens, topk selection
    maps = [[0 for _ in range(64)] for _ in range(64)] # 64 is the number of experts
    for rows in data:
        for i in rows:
            for j in rows:
                maps[i][j] += 1
                maps[j][i] += 1
    return maps

record = [[0.0 for _ in range(64)] for _ in range(64)]

if not file.exists():

    with ProcessPoolExecutor(max_workers=196) as executor:
        futures = [executor.submit(worker, file) for file in workspace.glob("*.pt")]
        for future in tqdm(as_completed(futures), total=len(futures), desc="Probing", ncols=80):
            result = future.result()
            for i in range(0, 64):
                for j in range(0, 64):
                    record[i][j] += result[i][j]

    for i in range(0, 64):
        base = record[i][i]
        for j in range(0, 64):
            record[i][j] /= base
        record[i][i] = 0

    with file.open('wb') as f: pickle.dump(record, f)

with file.open('rb') as f: record = pickle.load(f)

###
# Do the plotting.
###

K = 16
record = np.array(record)

# Step 1: Compute max co-activation for each expert (row-wise)
expert_max = record.max(axis=1)

# Step 2: Get top-K expert indices
top_expert_indices = np.argsort(expert_max)[-K:][::-1]  # descending

# Step 3: Extract submatrix (K x K) for those experts
filtered_record = record[top_expert_indices][:, top_expert_indices]

# Step 4: Plot
fig = plt.figure(figsize=(6, 6))
ax = plt.Axes(fig, [0., 0., 1., 1.])
fig.add_axes(ax)

cmap = LinearSegmentedColormap.from_list("white_to_black", ["white", "black"])
X, Y = np.meshgrid(np.arange(filtered_record.shape[1]+1), np.arange(filtered_record.shape[0]+1))

heatmap = ax.pcolormesh(X, Y, filtered_record, cmap=cmap, shading='auto')
ax.invert_yaxis()

# --- Expert IDs on X and Y ---
ax.set_xticks(np.arange(K)+0.5)
ax.set_yticks(np.arange(K)+0.5)
ax.set_xticklabels(top_expert_indices, fontsize=12)
ax.set_yticklabels(top_expert_indices, fontsize=12)

# Make ticks visible, but hide spines and tick lines
ax.tick_params(axis='both', which='both', length=0)
for spine in ax.spines.values():
    spine.set_visible(False)

file = Path(f"figures/expert-coactivation/{model_scale}/{ckpt_step}/{layer_num}.pdf")
file.parent.mkdir(parents=True, exist_ok=True)
plt.savefig(file, bbox_inches='tight', pad_inches=0)
