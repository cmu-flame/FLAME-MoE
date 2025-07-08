import matplotlib.pyplot as plt
from pathlib import Path
import seaborn as sns
import pandas as pd
import numpy as np
import wandb

###
# Header
###

MEDIUM_SIZE = 24
SMALLER_SIZE = 24
plt.rc("font", size=MEDIUM_SIZE)
plt.rc("axes", labelsize=MEDIUM_SIZE)
plt.rc("axes", titlesize=MEDIUM_SIZE)  # fontsize of the axes title
plt.rc("xtick", labelsize=SMALLER_SIZE)  # fontsize of the tick labels
plt.rc("ytick", labelsize=SMALLER_SIZE)  # fontsize of the tick labels
plt.rc("figure", titlesize=MEDIUM_SIZE)
plt.rc("legend", fontsize=MEDIUM_SIZE)

###
# Load and prepare data for plotting
###


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
    if run.state != "finished":
        continue
    flops = run.group.split("-").pop()
    loss = run.summary["lm loss validation"]
    num_layers, hidden_size = run.config["num_layers"], run.config["hidden_size"]
    selected = frontier[
        (frontier["num_layers"] == num_layers)
        & (frontier["hidden_size"] == hidden_size)
    ]
    active_params, total_params = (
        selected.iloc[0]["active_params"],
        selected.iloc[0]["total_params"],
    )
    active_params, total_params = parse_count(active_params), parse_count(total_params)
    data.append((flops, active_params, total_params, loss))

df = pd.DataFrame(data, columns=["flops", "active_params", "total_params", "loss"])

###
# Plotting
###

tartan_palette = ["#EF3A47", "#FDB515", "#009647", "#008F91", "#043673"]


def scaling_law(N, D):
    E, A, alpha, B, beta = 2.241716, 148.413257, 0.279702, 3269017.372472, 0.715500
    return E + A / (N**alpha) + B / (D**beta)


# Define sweep range: 1M to 1T parameters
param_range = np.logspace(6.5, 12, 500)  # 1M = 10^6, 1T = 10^12

# FLOPs budgets
budgets = []
for exp in range(17, 24):
    for coe in [1, 3, 6]:
        budgets.append(coe * (10**exp))

# Store results
opt_flops = []
opt_params = []

for budget in budgets:
    best_loss = np.inf
    best_param = None

    for N in param_range:
        D = budget / (6 * N)
        loss = scaling_law(N, D)
        if loss < best_loss:
            best_loss = loss
            best_param = N

    opt_flops.append(budget)
    opt_params.append(best_param)

exp_df = df.copy()
# Group by flops and find the row with minimum loss for each flops value
min_loss_idx = exp_df.groupby("flops")["loss"].idxmin()
filtered_df = exp_df.loc[min_loss_idx]
exp_flops = filtered_df["flops"].apply(float).to_numpy()
exp_active_params = filtered_df["active_params"].to_numpy()
# remove the second element from exp_flops and exp_active_params
exp_flops = np.delete(exp_flops, 1)
exp_active_params = np.delete(exp_active_params, 1)
print(exp_flops)
print(exp_active_params)

# Fit a line to the experimental data
opt_flops = np.array(opt_flops, dtype=float)
opt_params = np.array(opt_params, dtype=float)
fit = np.polyfit(np.log10(exp_flops), np.log10(exp_active_params), 1)
fit_line = 10 ** (fit[0] * np.log10(opt_flops) + fit[1])
print(fit[0], fit[1])

# Plotting
plt.figure(figsize=(6.8, 6))
plt.scatter(
    exp_flops,
    exp_active_params,
    color=tartan_palette[0],
    label="Empirical Optimal",
    marker="*",
    edgecolor="white",
    s=500,
)
plt.plot(
    opt_flops,
    fit_line,
    linewidth=2,
    color=tartan_palette[0],
    label="IsoFLOP Profiles",
)
plt.plot(
    opt_flops,
    opt_params,
    linewidth=2,
    # linestyle="--",
    color=tartan_palette[1],
    label="Parametric Loss",
)

plt.xscale("log")
plt.yscale("log")
plt.xlabel("Training FLOPs")
plt.ylabel("Active Parameters")
plt.legend(
    loc="upper left",
    frameon=False,
    ncol=1,
    fontsize=20,
    labelspacing=0.2,
    columnspacing=0.2,
    handletextpad=0.2,
)
plt.xticks([1e17, 1e19, 1e21, 1e23])
plt.yticks([1e7, 1e8, 1e9, 1e10, 1e11], ["10M", "100M", "1B", "10B", "100B"])
plt.tight_layout()
out_file = Path(f"figures/scaling_law/fitted_law.pdf")
out_file.parent.mkdir(parents=True, exist_ok=True)
plt.savefig(out_file, bbox_inches="tight", pad_inches=0.01)
