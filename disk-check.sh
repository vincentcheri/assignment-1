#!/bin/env sh

threshold=${1:-100}
path=${2:-/}

# integer handling
case "$threshold" in
    ''|*[!0-9]*) exit 2 ;;
esac

# check threshold range
if [ "$threshold" -lt 1 ] || [ "$threshold" -gt 100 ]; then
    exit 2
fi

# check if path exists
if [ ! -d "$path" ]; then
    exit 2
fi

# get disk usage
usage=$(df -P "$path" | tail -n 1)

# parse usage percentage
set -- $usage

# remove trailing percent sign
usage=${5%\%}

# print disk usage
printf 'Disk usage: %s%%\n' "$usage"

# check if usage is below threshold
[ "$usage" -lt "$threshold" ] && exit 0

# print warning message
exit 1
