import torch
import pickle
from tqdm import tqdm
from collections import defaultdict
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed

###
# Do the gathering.
###

mount, k = Path("/tmp/slurm-31207/actives"), 8
file = Path(f"results/router-saturation/flame-moe-1.7b/{k}.pkl")
file.parent.mkdir(parents=True, exist_ok=True)

def worker(ckpt_step: str, layer_number: str, probs_file: Path):
    saves = defaultdict(set)
    probs = torch.load(probs_file, map_location="cpu")
    for t, items in enumerate(probs.topk(k=k, dim=1).indices):
        saves[f"{probs_file.name}-{t}"] = set(items.tolist())
    return ckpt_step, layer_number, saves

if not file.exists():

    tasks = []
    ckpt_folder = sorted(mount.iterdir(), key=lambda p: int(p.name)).pop()
    ckpt_step = ckpt_folder.name

    for layer_folder in tqdm(sorted(ckpt_folder.iterdir(), key=lambda p: int(p.name)), desc="Discovering", ncols=80):
        layer_number, c = layer_folder.name, 0
        for probs_file in sorted(layer_folder.iterdir(), key=lambda p: p.name):
            if (c := c + 1) > 64: break
            tasks.append((ckpt_step, layer_number, probs_file))
            for other_ckpt_folder in sorted(mount.iterdir()):
                other_ckpt_step = other_ckpt_folder.name
                if other_ckpt_step == ckpt_step: continue
                other_probs_file = Path(str(probs_file).replace(ckpt_step, other_ckpt_step))
                assert other_probs_file.exists()
                tasks.append((other_ckpt_step, layer_number, other_probs_file))

    futures, maps = [], dict()
    with ProcessPoolExecutor(max_workers=64) as executor:
        for t in tasks:
            futures.append(executor.submit(worker, *t))
        for future in tqdm(as_completed(futures), total=len(futures), desc="Calculating", ncols=80):
            ckpt_step, layer_number, saves = future.result()
            if ckpt_step not in maps: maps[ckpt_step] = dict()
            if layer_number not in maps[ckpt_step]: maps[ckpt_step][layer_number] = dict()
            for key, val in saves.items():
                maps[ckpt_step][layer_number][key] = val

    record = dict()
    last_ckpt_step = max(maps.keys(), key=int)

    for ckpt_step, inner1 in maps.items():
        if ckpt_step == last_ckpt_step: continue
        for layer_number, inner2 in inner1.items():
            for token_id, expert_ids in inner2.items():
                last_expert_ids = maps[last_ckpt_step][layer_number][token_id]
                maps[ckpt_step][layer_number][token_id] = len(expert_ids.intersection(last_expert_ids)) / k

    for ckpt_step, inner1 in maps.items():
        if ckpt_step == last_ckpt_step: continue
        for layer_number, inner2 in inner1.items():
            if ckpt_step not in record: record[ckpt_step] = dict()
            record[ckpt_step][layer_number] = sum(inner2.values()) / len(inner2)

    with file.open("wb") as f: pickle.dump(record, f)

###
# Do the plotting.
###
