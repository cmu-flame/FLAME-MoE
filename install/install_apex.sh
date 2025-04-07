#!/bin/bash

set -e
set -u
set -o pipefail

pushd apex
export TORCH_CUDA_ARCH_LIST=9.0+PTX
export MAX_JOBS=64
pip3 install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
popd
