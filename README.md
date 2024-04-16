# Handle simple monitoring questions on debian servers via SSH

## How to install 

1. Clone the repo on the server 
2. Force a system user to only used the elab-monitor.sh script 
3. then you can `ssh $system_user@yourserver question`

## Questions available 

- disk_size
- disk_available
- disk_used
- disk_used_percent
- disk_available_percent

- memory_size
- memory_available
- memory_used
- memory_used_percent
- memory_available_percent