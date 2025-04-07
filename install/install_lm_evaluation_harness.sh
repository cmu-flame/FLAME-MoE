#!/bin/bash

set -e
set -u
set -o pipefail

pushd lm-evaluation-harness
pip install -e . -v
popd
