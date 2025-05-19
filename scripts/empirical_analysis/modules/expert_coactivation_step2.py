import argparse
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed
from typing import List

import torch
import pickle
from tqdm import tqdm

num_experts = 64
max_workers = 128

def work(actives_file: Path) -> List[List[float]]:
    _, indices = torch.load(actives_file, map_location="cpu")
    record = [[0.0 for _ in range(num_experts)] for _ in range(num_experts)]
    for row in indices:
        for i in row:
            for j in row:
                record[i][j] += 1.0
                record[j][i] += 1.0
    return record

def main():
    # parse the arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--actives-path", type=str, required=True)
    parser.add_argument("--results-path", type=str, required=True)
    parsed = parser.parse_args()    

    # run sanity check
    actives_path = Path(parsed.actives_path)
    assert actives_path.is_dir()
    results_path = Path(parsed.results_path)
    assert results_path.name.endswith("pkl")
    if results_path.is_file(): return

    # prepare the execution
    results_path.parent.mkdir(parents=True, exist_ok=True)
    record = [[0.0 for _ in range(num_experts)] for _ in range(num_experts)]
    args, jobs = [], []

    # compute the expert coactivation
    # 1. find the occurences where experts i and j are both active
    # 2. normalize by the occurences where expert i is active regardless of others
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        for actives_file in sorted(actives_path.iterdir()):
            args.append(actives_file)
        for arg in args:
            jobs.append(executor.submit(work, arg))
        for future in tqdm(as_completed(jobs), total=len(jobs), desc=f"Processing", ncols=80, mininterval=5):
            result = future.result()
            for i in range(num_experts):
                for j in range(num_experts):
                    record[i][j] += result[i][j]
    for i in range(num_experts):
        base = record[i][i] if record[i][i] != 0 else 1
        for j in range(num_experts):
            record[i][j] /= base
        record[i][i] = 0

    # dump the result to avoid re-computation
    with results_path.open('wb') as f:
        pickle.dump(record, f)

if __name__ == "__main__":
    main()
