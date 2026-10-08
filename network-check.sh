#!/bin/bash

ip=$1
port=$2

log_event() {
    mkdir -p logs || {
        printf 'Unable to create logs directory\n' >&2
        return 1
    }
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> logs/network-check.log || {
        printf 'Unable to write logs/network-check.log\n' >&2
        return 1
    }
}

log_event "Network check started" || exit 1

if (( $# < 1 || $# > 2 )) ||
    [[ ! $ip =~ ^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
    printf 'Usage: %s IPv4-address [port]\n' "$0" >&2
    exit 2
fi

if (( $# == 2 )); then
    if [[ ! $port =~ ^0*([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$ ]]; then
        printf 'Invalid port: %s (valid range: 1-65535)\n' "$port" >&2
        exit 2
    fi
    port=${BASH_REMATCH[1]}
fi

resolved=
read -r resolved _ < <(getent ahostsv4 "$ip")
if [[ -z $resolved ]]; then
    printf 'Unable to resolve IP address: %s\n' "$ip" >&2
    exit 1
fi
printf 'Resolved address: %s\n' "$resolved"

result=0
if ! command -v ping >/dev/null 2>&1; then
    printf 'Connectivity check unavailable: ping is not installed\n' >&2
    result=1
elif ping -c 1 -W 2 "$resolved" >/dev/null 2>&1; then
    printf 'Connectivity check succeeded\n'
else
    printf 'Connectivity check failed\n'
    result=1
fi

printf 'Network interfaces:\n'
ip address show || result=1

if (( $# == 2 )); then
    if timeout 2 bash -c ':</dev/tcp/"$1"/"$2"' _ "$resolved" "$port" 2>/dev/null; then
        printf 'TCP connection to %s:%s succeeded\n' "$resolved" "$port"
    else
        printf 'TCP connection to %s:%s failed\n' "$resolved" "$port"
        result=1
    fi
fi

exit "$result"
