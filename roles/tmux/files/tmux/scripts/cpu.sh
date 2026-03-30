#!/usr/bin/env bash
cpuvalue=$(ps -A -o %cpu | awk -F. 'NR>1{s+=$1} END{print s}')
cpucores=$(sysctl -n hw.logicalcpu)
echo "$((cpuvalue / cpucores))%"
