import wandb
import pandas as pd

"""
Construct the dataset.
"""

def parse_count(s: str) -> int:
    s = s.strip().upper()
    if s.endswith("B"):
        return int(float(s[:-1]) * 1_000_000_000)
    elif s.endswith("M"):
        return int(float(s[:-1]) * 1_000_000)
    elif s.endswith("K"):
        return int(float(s[:-1]) * 1_000)
    return int(float(s))

api, data = wandb.Api(), []
frontier = pd.read_csv("https://docs.google.com/spreadsheets/d/1sIr9HRwYbUXKzlskUTMorMa2A_cAzDwE0eUJnk-W1dQ/export?format=csv&gid=1059339506")

for run in api.runs("haok/flame-moe", {"group": {"$regex": "ablation"}}):
    if run.state != "finished": continue
    flops = float(run.group.split("-").pop())  # <--- parse flops as float here
    loss = run.summary["lm loss validation"]
    num_layers, hidden_size = run.config["num_layers"], run.config["hidden_size"]
    selected = frontier[(frontier["num_layers"] == num_layers) & (frontier["hidden_size"] == hidden_size)]
    active_params, total_params = selected.iloc[0]["active_params"], selected.iloc[0]["total_params"]
    active_params, total_params = parse_count(active_params), parse_count(total_params)
    data.append((flops, active_params, total_params, loss))

df = pd.DataFrame(data, columns=["flops", "active_params", "total_params", "loss"])
print(df.head(3))

"""
Do the plotting.
"""

import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# Step 1: create a consistent flops → color map
unique_flops = np.sort(df['flops'].unique())  # <--- sort flops numerically
palette = sns.color_palette("viridis", as_cmap=False, n_colors=len(unique_flops))
flops_to_color = dict(zip(unique_flops, palette))

# --- Plot 1: Active Parameters ---
plt.figure(figsize=(8,6))

sns.scatterplot(
    data=df,
    x="active_params",
    y="loss",
    hue="flops",
    palette=flops_to_color,
    legend="full",
    s=80
)

for flops in unique_flops:
    subset = df[df['flops'] == flops].sort_values("active_params")
    z = np.polyfit(np.log10(subset["active_params"]), subset["loss"], deg=2)
    x_fit = np.logspace(np.log10(subset["active_params"].min()), np.log10(subset["active_params"].max()), 200)
    y_fit = z[0]*np.log10(x_fit)**2 + z[1]*np.log10(x_fit) + z[2]
    plt.plot(x_fit, y_fit, linestyle='--', color=flops_to_color[flops])

plt.xscale('log')
plt.xlabel("Active Parameters")
plt.ylabel("Training Loss")
plt.title("Training Loss vs Active Parameters")
plt.legend(title="FLOPs", bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.savefig("logs/training_loss_vs_active_parameters.png", dpi=300)
plt.close()

# --- Plot 2: Total Parameters ---
plt.figure(figsize=(8,6))

sns.scatterplot(
    data=df,
    x="total_params",
    y="loss",
    hue="flops",
    palette=flops_to_color,
    legend="full",
    s=80
)

for flops in unique_flops:
    subset = df[df['flops'] == flops].sort_values("total_params")
    z = np.polyfit(np.log10(subset["total_params"]), subset["loss"], deg=2)
    x_fit = np.logspace(np.log10(subset["total_params"].min()), np.log10(subset["total_params"].max()), 200)
    y_fit = z[0]*np.log10(x_fit)**2 + z[1]*np.log10(x_fit) + z[2]
    plt.plot(x_fit, y_fit, linestyle='--', color=flops_to_color[flops])

plt.xscale('log')
plt.xlabel("Total Parameters")
plt.ylabel("Training Loss")
plt.title("Training Loss vs Total Parameters")
plt.legend(title="FLOPs", bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.savefig("logs/training_loss_vs_total_parameters.png", dpi=300)
plt.close()
