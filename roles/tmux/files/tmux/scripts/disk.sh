#!/usr/bin/env bash
disk_used=$(df -h / | tail -n 1 | awk '{print $3}')
disk_size=$(df -h / | tail -n 1 | awk '{print $2}')
echo "${disk_used}/${disk_size}"
