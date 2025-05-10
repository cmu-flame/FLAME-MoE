#!/bin/bash

for layer_number in {9,}; do
    for expert_index in {0..63}; do
        for checkpoint_step in {11029,}; do
            timeout 10m python3 empirical_analysis/work/expert_specialization.py \
                --layer-number $layer_number --expert-index $expert_index --checkpoint-step $checkpoint_step
        done
    done
done
