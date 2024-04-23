#!/bin/bash

mkdir -p /var/log/monitoring

LOG="/var/log/monitoring/elab-monitor.log"

ssh_connection=(${SSH_CONNECTION})
SSH_SOURCE_IP="${ssh_connection[0]}:${ssh_connection[1]}"

log() {
    printf "%s [%s] %s - %s\n" \
           "$(date --rfc-3339=seconds)" "$$" "$SSH_SOURCE_IP" "$*" \
           >> "$LOG"
}

log "NEW MONITORING CONNECTION"

ident="$1"
log "IDENTIFIED AS $ident"

reject() {
    log "REJECTED: $SSH_ORIGINAL_COMMAND"
    # echo "ORIG: $SSH_ORIGINAL_COMMAND" >&2
    echo "Your command has been rejected and reported to sys admin." >&2
    exit 1
}

## TODO:  check how it’s made in the original script
# sudo /usr/local/sbin/ssh-update-keys

if [[ "$SSH_ORIGINAL_COMMAND" =~ [\&\(\{\;\<\>\`\$\}] ]]; then
    log "BAD CHARS DETECTED"
    # echo "Bad chars: $SSH_ORIGINAL_COMMAND" >&2
    reject
fi

disk_size() {
    val=$(df | awk '/\/$/ {print $2}')  # Retrieves the total disk size of the root filesystem
    echo "$val"
}

disk_available() {
    val=$(df | awk '/\/$/ {print $4}')  # Retrieves the available disk space of the root filesystem
    echo "$val"
}

disk_used() {
    val=$(df | awk '/\/$/ {print $3}')  # Retrieves the used disk space of the root filesystem
    echo "$val"
}

disk_used_percent() {
    val=$(df | awk '/\/$/ {print $5}')  # Retrieves the percentage of used disk space of the root filesystem
    echo "$val"
}

disk_available_percent() {
    val=$(df | awk '/\/$/ {print $4}')  # Retrieves the percentage of available disk space of the root filesystem
    echo "$val"
}

memory_size() {
    val=$(free | awk '/Mem:/ {print $2}')  # Retrieves the total memory size
    echo "$val"
}

memory_available() {
    val=$(free | awk '/Mem:/ {print $7}')  # Retrieves the available memory
    echo "$val"
}

memory_used() {
    val=$(free | awk '/Mem:/ {print $3}')  # Retrieves the used memory
    echo "$val"
}

memory_used_percent() {
    val=$(free | awk '/Mem:/ {printf "%.2f\n", (($2 - $7) / $2) * 100}')  # Calculates the percentage of used memory
    echo "$val"
}

memory_available_percent() {
    val=$(free | awk '/Mem:/ {printf "%.2f\n", ($7 / $2) * 100}')  # Calculates the percentage of available memory
    echo "$val"
}

## ---- MAIN ----

if [[ $SSH_ORIGINAL_COMMAND =~ ^[a-zA-Z0-9_]+$ ]]; then
    log "ACCEPTED monitoring COMMAND : $SSH_ORIGINAL_COMMAND"
    case "$SSH_ORIGINAL_COMMAND" in
        disk_size) disk_size ;;
        disk_available) disk_available ;;
        disk_used) disk_used ;;
        disk_used_percent) disk_used_percent ;;
        disk_available_percent) disk_available_percent ;;
        memory_size) memory_size ;;
        memory_available) memory_available ;;
        memory_used) memory_used ;;
        memory_used_percent) memory_used_percent ;;
        memory_available_percent) memory_available_percent ;;
        *) reject ;;
    esac
else
    reject
fi