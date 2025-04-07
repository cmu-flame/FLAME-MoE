#!/bin/bash

set -e
set -u
set -o pipefail

pushd lm-evaluation-harness
pip3 install -e . -v
popd
