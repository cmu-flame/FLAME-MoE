import re
from pathlib import Path
from typing import List, Optional

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

pattern = re.compile(r"""
    iteration\s+
    (\d+)/\s*
    \d+\s+
    \|.*?
    elapsed\ time\ per\ iteration\ \(ms\):\s+
    ([\d.]+)\s+
    \|
    \ throughput\ per\ GPU\ \(TFLOP/s/GPU\):\s+
    ([\d.]+)
    """, re.VERBOSE)

def plot(file: Path, mode: str, title: str, label: Optional[str] = None):
    x: List[int] = []
    y: List[float] = []
    with file.open("r") as f:
        for line in f:
            found = re.search(pattern, line)
            if not found: continue
            x.append(int(found.group(1)))
            y.append(float(found.group(2 if mode == "latency" else 3)))
    df = pd.DataFrame({"x": x, "y": y})
    if mode == "latency": df["y"] = df["y"].apply(lambda x: x / 1000)
    sns.lineplot(
        data=df, x="x", y="y", label=label, 
        linestyle="solid" if mode == "latency" else "dotted", marker="o",
        linewidth=3, markersize=9
    )
    # plt.title(title, fontsize=24)
    plt.gca().set_ylabel("Elapsed Time per Step (s)" if mode == "latency" else "Throughput (TFLOPS/s/GPU)", fontsize=24)
    plt.gca().set_xlabel("Training Step", fontsize=24)
    plt.gca().tick_params(axis='both', labelsize=20)
    plt.legend(frameon=False, fontsize=16)

def dump(file: Path):
    file.parent.mkdir(parents=True, exist_ok=True)
    plt.tight_layout()
    plt.savefig(file, bbox_inches='tight', pad_inches=0)
    plt.close()

w, h = 6, 6

plt.figure(figsize=(w, h))
plot(Path("ep=2,pp=1,bs=1.log"), "latency", "PP=1", "EP=2")
plot(Path("ep=4,pp=1,bs=2.log"), "latency", "PP=1", "EP=4")
plot(Path("ep=8,pp=1,bs=4.log"), "latency", "PP=1", "EP=8")
dump(Path("figures/infrastructure/pp1_latency.pdf"))

plt.figure(figsize=(w, h))
plot(Path("ep=1,pp=2,bs=4.log"), "latency", "PP=2", "EP=1")
plot(Path("ep=2,pp=2,bs=4.log"), "latency", "PP=2", "EP=2")
plot(Path("ep=4,pp=2,bs=4.log"), "latency", "PP=2", "EP=4")
dump(Path("figures/infrastructure/pp2_latency.pdf"))

plt.figure(figsize=(w, h))
plot(Path("ep=2,pp=1,bs=1.log"), "throughput", "PP=1", "EP=2")
plot(Path("ep=4,pp=1,bs=2.log"), "throughput", "PP=1", "EP=4")
plot(Path("ep=8,pp=1,bs=4.log"), "throughput", "PP=1", "EP=8")
dump(Path("figures/infrastructure/pp1_throughput.pdf"))

plt.figure(figsize=(w, h))
plot(Path("ep=1,pp=2,bs=4.log"), "throughput", "PP=2", "EP=1")
plot(Path("ep=2,pp=2,bs=4.log"), "throughput", "PP=2", "EP=2")
plot(Path("ep=4,pp=2,bs=4.log"), "throughput", "PP=2", "EP=4")
dump(Path("figures/infrastructure/pp2_throughput.pdf"))
