#!/bin/bash
# This script was generated with the assistance of GPT-4.

# Check if a file argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path_to_log_file>"
    exit 1
fi

log_file="$1"

# Check if the file exists
if [ ! -f "$log_file" ]; then
    echo "Error: File '$log_file' not found!"
    exit 1
fi

# Function to compute median from sorted values
compute_median() {
    local -n arr=$1
    local len=${#arr[@]}

    if (( len == 0 )); then
        echo "N/A"
        return
    elif (( len % 2 == 1 )); then
        echo "${arr[$((len / 2))]}"
    else
        local mid=$((len / 2))
        echo "scale=2; (${arr[mid-1]} + ${arr[mid]}) / 2" | bc
    fi
}

# Extract and sort throughput values
tflops_values=$(grep -oP 'throughput per GPU \(TFLOP/s/GPU\): \K[\d.]+' "$log_file" | sort -n)
readarray -t tflops_arr <<<"$tflops_values"

# Extract and sort elapsed time values
elapsed_values=$(grep -oP 'elapsed time per iteration \(ms\): \K[\d.]+' "$log_file" | sort -n)
readarray -t elapsed_arr <<<"$elapsed_values"

# Compute medians
median_tflops=$(compute_median tflops_arr)
median_elapsed=$(compute_median elapsed_arr)

# Print results
echo "Median TFLOPS/s/GPU: $median_tflops"
echo "Median elapsed time per iteration (ms): $median_elapsed"
