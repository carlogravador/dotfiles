#!/usr/bin/env bash

OS="$(uname)"

if [ $OS = "Darwin" ]; then
    cpuvalue=$(ps -A -o %cpu | awk -F. 'NR>1{s+=$1} END{print s}')
    cpucores=$(sysctl -n hw.logicalcpu)
    echo "$((cpuvalue / cpucores))%"
elif [ "$OS" = "Linux" ]; then
    cpucores=$(nproc)
    cpu_idle=$(awk '/^cpu / {
        idle=$5
        total=0
        for(i=2;i<=NF;i++) total+=$i
        printf "%.0f", (idle/total)*100
    }' /proc/stat) 
    cpu_used=$((100 - cpu_idle))
    echo "${cpu_used}%"
fi
