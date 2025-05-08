import torch
import itertools
import numpy as np
from tqdm import tqdm
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from collections import defaultdict
from typing import List
from concurrent.futures import ProcessPoolExecutor, as_completed

l0, l1 = 2, 5
# l0, l1 = 9, 12

plt.figure(figsize=(8, 5))

def worker(data: List[List[List[int]]]):
    maps = defaultdict(int)
    for line in tqdm(data):
        for item in itertools.product(*line):
            path = "-".join(map(str, item))
            maps[path] += 1
    return maps

# glob_2_5 = [torch.load(f"/tmp/slurm-31207/actives/880/{layer_number}/tops-99-4.pt", map_location="cpu") for layer_number in range(2, 5 + 1)]
# data_2_5 = torch.stack(glob_2_5, dim=1).cpu().numpy().tolist()
# maps_2_5 = worker(data_2_5)
# vals_2_5 = maps_2_5.values()
# bins_2_5 = np.arange(min(vals_2_5), max(vals_2_5) + 2) - 0.5
# sns.histplot(vals_2_5, bins=bins_2_5, kde=True, edgecolor="black", color='C0', label='Layer 2-5')

# glob_9_12 = [torch.load(f"/tmp/slurm-31207/actives/880/{layer_number}/tops-99-4.pt", map_location="cpu") for layer_number in range(9, 12 + 1)]
# data_9_12 = torch.stack(glob_9_12, dim=1).cpu().numpy().tolist()
# maps_9_12 = worker(data_9_12)
# vals_9_12 = maps_9_12.values()
# bins_9_12 = np.arange(min(vals_9_12), max(vals_9_12) + 2) - 0.5
# sns.histplot(vals_9_12, bins=bins_9_12, kde=True, edgecolor="black", color='C2', label='Layer 8-11')

# plt.xlabel('Value')
# plt.ylabel('Frequency')
# plt.xlim(0, 10)

# plt.savefig(f'main.png', dpi=300)

def plot_path_graph(maps, layer_range, title):
    plt.figure(figsize=(12, 5))

    # Prepare layer ids
    layers = list(range(layer_range[0], layer_range[1] + 1))

    # Calculate counts for normalization
    counts = np.array(list(maps.values()))
    max_count = counts.max()

    for path, count in tqdm(maps.items()):
        expert_ids = [int(e) for e in path.split("-")]
        alpha = 0.2 + 0.8 * (count / max_count)  # More frequent -> more visible

        # Plot line
        plt.plot(layers, expert_ids, marker='D', markersize=6, linewidth=2, alpha=alpha)

    plt.xlabel("MoE Layer idx")
    plt.ylabel("Expert idx")
    plt.title(title)
    plt.xticks(layers)
    plt.grid(True, linestyle='--', alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"figures/routing-dynamics/flame-moe-721m/880/{layer_range[0]}-{layer_range[1]}.png", dpi=300)

glob_2_5 = [torch.load(f"/tmp/slurm-31207/actives/880/{layer_number}/tops-99-4.pt", map_location="cpu") for layer_number in range(2, 5 + 1)]
data_2_5 = torch.stack(glob_2_5, dim=1).cpu().numpy().tolist()
maps_2_5 = worker(data_2_5)

plot_path_graph(maps_2_5, layer_range=(2, 5), title="Layer 2-5 Path Flow")

glob_9_12 = [torch.load(f"/tmp/slurm-31207/actives/880/{layer_number}/tops-99-4.pt", map_location="cpu") for layer_number in range(9, 12 + 1)]
data_9_12 = torch.stack(glob_9_12, dim=1).cpu().numpy().tolist()
maps_9_12 = worker(data_9_12)

plot_path_graph(maps_9_12, layer_range=(9, 12), title="Layer 9-12 Path Flow")
