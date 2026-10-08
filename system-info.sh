#!/bin/env sh

echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date: $(date)"
echo "Operating System: $(uname -s)"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "CPUinformation: $(lscpu)"
echo "Memoryinformation: $(free -h)"
echo "Currentworkingdirectory: $(pwd)"
