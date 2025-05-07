#!/bin/bash

env | grep '^SLURM' | sed "s/^\(.*\)=\(.*\)$/export \1='\2'/" > .env.$(hostname)
