#!/usr/bin/env bash

OS=$(uname)
if [ "$OS" = "Darwin" ]; then
    used_pages=$(vm_stat | awk '
    /Pages active:/              { a=$NF+0 }
    /Pages wired down:/          { w=$NF+0 }
    /Pages occupied by compressor:/ { c=$NF+0 }
    /Pages speculative:/         { s=$NF+0 }
    END { print a+w+c+s }
    ')
    page_size=$(pagesize)
    used_mb=$((used_pages * page_size / 1048576))
    total_gb=$(sysctl -n hw.memsize | awk '{print int($1/1073741824)}')

    if [ "$used_mb" -lt 1024 ]; then
    echo "${used_mb}MB/${total_gb}GB"
    else
    echo "$((used_mb / 1024))GB/${total_gb}GB"
    fi
elif [ "$OS" = "Linux" ]; then
    mem_info=$(free -m | awk '/^Mem:/ {print $3, $2}')
    used_mb=$(echo "$mem_info" | awk '{print $1}')
    total_mb=$(echo "$mem_info" | awk '{print $2}')
    total_gb=$((total_mb / 1024))

    if [ "$used_mb" -lt 1024 ]; then
        echo "${used_mb}MB/${total_gb}GB"
    else
        echo "$((used_mb / 1024))GB/${total_gb}GB"
    fi
fi
