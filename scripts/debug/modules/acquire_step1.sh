#!/bin/bash

env | grep '^SLURM' | sed 's/^/export /' > .env.$(hostname)
