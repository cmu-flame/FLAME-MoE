import os
import glob
import argparse
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed
from typing import List, Tuple

import torch
import pickle
import numpy as np
from tqdm import tqdm

num_experts = 64
max_workers = 196

def work(name: str, actives_glob: List[Path], moe_router_topk: int):
    last_actives_path = Path(actives_glob[-1], name)
    _, last_indices = torch.load(last_actives_path, map_location="cpu")
    last_indices = last_indices[:, :moe_router_topk].numpy()
    record: List[List[float, int]] = []
    for actives_path in map(lambda x: Path(x, name), actives_glob):
        _, indices = torch.load(actives_path, map_location="cpu")
        indices = indices[:, :moe_router_topk].numpy()
        assert indices.shape == last_indices.shape
        x, y = 0.0, indices.shape[0]
        for a, b in zip(indices, last_indices):
            x += (np.isin(a, b, assume_unique=True).sum() / moe_router_topk)
        record.append([x, y])
    return record

def main():
    # parse the arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--moe-router-topk", type=int, required=True)
    parser.add_argument("--actives-pattern", type=str, required=True)
    parser.add_argument("--results-path", type=str, required=True)
    parsed = parser.parse_args()

    print("moe-router-topk:", parsed.moe_router_topk)
    print("actives-pattern:", parsed.actives_pattern)
    print("   results-path:", parsed.results_path)

    # gather the actives_path for this specific layer across all the training steps
    actives_glob = sorted(
        (
            Path(d)
            for d in glob.glob(parsed.actives_pattern, recursive=True)
            if os.path.isdir(d)
        ),
        key=lambda x: int(x.parts[4])
    )

    # run sanity check
    assert len(actives_glob) > 0
    first_count = sum(1 for _ in actives_glob[0].glob("*.pt"))
    for actives_path in actives_glob:
        count = sum(1 for _ in actives_path.glob("*.pt"))
        assert count == first_count
    moe_router_topk = int(parsed.moe_router_topk)
    assert moe_router_topk > 0
    results_path = Path(parsed.results_path)
    assert results_path.name.endswith("pkl")
    if results_path.is_file(): return

    # prepare the execution
    results_path.parent.mkdir(parents=True, exist_ok=True)
    record: List[List[float, int]] = [[0.0, 0] for _ in range(len(actives_glob))]
    args, jobs = [], []

    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        for active_file in sorted(actives_glob[0].glob("*.pt")):
            args.append((active_file.name, actives_glob, moe_router_topk))
        for arg in args:
            jobs.append(executor.submit(work, *arg))
        for future in tqdm(as_completed(jobs), total=len(jobs), desc=f"Processing", ncols=80, mininterval=5):
            result = future.result()
            assert len(result) == len(actives_glob)
            for i, (x, y) in enumerate(result):
                record[i][0] += x
                record[i][1] += y
    record: List[float] = list(map(lambda x: x[0] / x[1], record))

    # dump the result to avoid re-computation
    with results_path.open('wb') as f:
        pickle.dump(record, f)

if __name__ == "__main__":
    main()
