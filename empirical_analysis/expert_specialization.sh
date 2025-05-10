#!/bin/bash

for checkpoint_step in {1100,2200,3300,4400}; do
    for layer_number in {18,}; do
        for expert_index in {0..64}; do
            timeout 10m python3 empirical_analysis/work/expert_specialization.py \
                --layer-number $layer_number --expert-index $expert_index --checkpoint-step $checkpoint_step
        done
    done
done

for checkpoint_step in {5500,6600,7700}; do
    for layer_number in {18,}; do
        for expert_index in {0..64}; do
            timeout 10m python3 empirical_analysis/work/expert_specialization.py \
                --layer-number $layer_number --expert-index $expert_index --checkpoint-step $checkpoint_step
        done
    done
done

for checkpoint_step in {8800,9900,11029}; do
    for layer_number in {18,}; do
        for expert_index in {0..64}; do
            timeout 10m python3 empirical_analysis/work/expert_specialization.py \
                --layer-number $layer_number --expert-index $expert_index --checkpoint-step $checkpoint_step
        done
    done
done
