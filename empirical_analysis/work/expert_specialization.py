"""
@file: expert_specialization.py
@brief: Calculate the specialization score for a particular expert using the test set.
"""

import argparse
from pathlib import Path
from typing import Tuple, List
from concurrent.futures import ProcessPoolExecutor, as_completed, Future

import torch
from tqdm import tqdm
from torch import Tensor

def job_step1(sample_path: Path, active_path: Path, expert_index: int, moe_router_topk: int = 6) -> Tuple[Tensor, Tensor]:
    """
    :return:
        sample_count (Tensor): A tensor counting how many times each token ID appears in the sample.
        active_count (Tensor): A tensor counting how many times each token ID activates the specified expert in the sample.
    """
    sample: Tensor = torch.load(sample_path, map_location="cpu")
    sample_count = torch.bincount(sample, minlength=50277)
    active: Tensor = torch.load(active_path, map_location="cpu")
    expert_indices = active.topk(k=moe_router_topk).indices
    mask: Tensor = (expert_indices == expert_index)
    sample = sample[mask.any(dim=1)]
    active_count = torch.bincount(sample, minlength=50277)
    return sample_count, active_count

def job_step0(layer_number: int, expert_index: int, checkpoint_step: int):

    print(f"Analyzing : layer_number = {layer_number}, expert_index = {expert_index}, checkpoint_step = {checkpoint_step}")

    # Skip completed work
    dump_path = Path(f"/project/flame/haok/results/expert-specialization/flame-moe-1.7b/{checkpoint_step}/{layer_number}-{expert_index}.pt")
    if dump_path.exists(): return

    # Discover the jobs
    actives = Path("/tmp/slurm-31207/actives")
    samples = Path("/tmp/slurm-31207/samples")
    args: List[Tuple[Path, Path, int, int]] = []
    for sample_path in samples.iterdir():
        active_path = Path(actives, str(checkpoint_step), str(layer_number), sample_path.name)
        args.append((sample_path, active_path, expert_index))

    # Run the jobs and store their returns
    jobs: List[Future] = []
    barrier: List[Tuple[Tensor, Tensor]] = []
    with ProcessPoolExecutor(max_workers=24) as executor:
        for a in args:
            jobs.append(executor.submit(job_step1, *a))
        for j in tqdm(as_completed(jobs), total=len(jobs), desc="Working", ncols=80):
            barrier.append(j.result())

    # Gather the final result
    sample_count = torch.zeros(50277, dtype=torch.int64)
    active_count = torch.zeros(50277, dtype=torch.int64)
    for s, a in tqdm(barrier, desc="Gathering", ncols=80):
        sample_count += s
        active_count += a

    # Dump to file for visualization
    dump_path.parent.mkdir(parents=True, exist_ok=True)    
    torch.save((sample_count, active_count), dump_path)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--layer-number", type=int, default=18)
    parser.add_argument("--expert-index", type=int, default=24)
    parser.add_argument("--checkpoint-step", type=int, default=11029)
    parsed = parser.parse_args()
    assert 2 <= parsed.layer_number <= 18
    assert 0 <= parsed.expert_index <= 63
    job_step0(parsed.layer_number, parsed.expert_index, parsed.checkpoint_step)

if __name__ == "__main__":
    main()
