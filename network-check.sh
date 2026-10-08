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
log_event "Validating IPv4 address and optional port" || exit 1

if (( $# < 1 || $# > 2 )) ||
    [[ ! $ip =~ ^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
    log_event "IPv4 validation failed" || exit 1
    printf 'Usage: %s IPv4-address [port]\n' "$0" >&2
    exit 2
fi

if (( $# == 2 )); then
    if [[ ! $port =~ ^0*([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$ ]]; then
        log_event "Port validation failed" || exit 1
        printf 'Invalid port: %s (valid range: 1-65535)\n' "$port" >&2
        exit 2
    fi
    port=${BASH_REMATCH[1]}
fi
log_event "Input validation succeeded" || exit 1

resolved=
log_event "Resolving $ip" || exit 1
read -r resolved _ < <(getent ahostsv4 "$ip")
if [[ -z $resolved ]]; then
    log_event "Resolution failed for $ip" || exit 1
    printf 'Unable to resolve IP address: %s\n' "$ip" >&2
    exit 1
fi
printf 'Resolved address: %s\n' "$resolved"
log_event "Resolved $ip to $resolved" || exit 1

result=0
log_event "Checking connectivity to $resolved" || result=1
if ping -c 1 -W 2 "$resolved" >/dev/null 2>&1; then
    printf 'Connectivity check succeeded\n'
    log_event "Connectivity check succeeded for $resolved" || result=1
else
    printf 'Connectivity check failed\n'
    log_event "Connectivity check failed for $resolved" || result=1
    result=1
fi

printf 'Network interfaces:\n'
log_event "Displaying network interfaces" || result=1
if ip address show; then
    log_event "Network interfaces displayed" || result=1
else
    log_event "Failed to display network interfaces" || result=1
    result=1
fi

if (( $# == 2 )); then
    log_event "Checking TCP connection to $resolved port $port" || result=1
    if timeout 2 bash -c ':</dev/tcp/"$1"/"$2"' _ "$resolved" "$port" 2>/dev/null; then
        printf 'TCP connection to %s:%s succeeded\n' "$resolved" "$port"
        log_event "TCP connection succeeded for $resolved port $port" || result=1
    else
        printf 'TCP connection to %s:%s failed\n' "$resolved" "$port"
        log_event "TCP connection failed for $resolved port $port" || result=1
        result=1
    fi
fi

if (( result == 0 )); then
    log_event "Network check completed successfully" || result=1
else
    log_event "Network check completed with failures" || result=1
fi

exit "$result"
