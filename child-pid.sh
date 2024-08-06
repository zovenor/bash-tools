#!/bin/bash

# Check if the number of arguments is either 2 or 3
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <parent_pid> <command_name> [ssh_host]"
    exit 1
fi

# Assign the arguments to variables
parent_pid=$1
command_name=$2
ssh_host=$3

# Determine the ps command based on whether ssh_host is provided
if [ -z "$ssh_host" ]; then
    ps_command="ps -e -o pid,ppid,comm,etime"
else
    ps_command="ssh $ssh_host 'ps -e -o pid,ppid,comm,etime'"
fi

# Create a temporary file to store process information
temp_file=$(mktemp)

# Function to find child processes recursively
find_child_processes() {
    local pid=$1
    # Capture the output and exit status of the eval command
    local output
    output=$(eval "$ps_command" 2>&1)
    local eval_exit_status=$?

    # Check if the eval command succeeded
    if [ $eval_exit_status -ne 0 ]; then
        case "$screen_output" in
          *"ssh:"* | *"Connection closed by"* | *"kex_exchange_identification"*)
            echo "SSH connection to $ssh_host failed."
            exit 1
            ;;
        esac
        rm "$temp_file"
        echo "SSH connection to $ssh_host failed."
        exit 1
    fi

    # Parse the output and find child processes
    echo "$output" | awk -v ppid="$pid" '$2 == ppid {print $1, $3, $4}' >> "$temp_file"
    
    local child_pids
    child_pids=$(echo "$output" | awk -v ppid="$pid" '$2 == ppid {print $1}')
    for child_pid in $child_pids; do
        find_child_processes "$child_pid"
    done
}

# Start finding child processes from the given parent PID
find_child_processes "$parent_pid"

# Sort the processes by command name and elapsed time
sorted_file=$(mktemp)
awk '{ print $1, $2 " " $3 " " $4 }' "$temp_file" | sort -k2,2 -k3,3 -k4,4 > "$sorted_file"

# Find the latest process with the specified command name
latest_pid=$(grep -w "$command_name" "$sorted_file" | tail -n 1 | awk '{print $1}')

# Clean up temporary files
rm "$temp_file"
rm "$sorted_file"

# Check if a PID was found and print appropriate messages
if [ -z "$latest_pid" ]; then
    echo "No child processes found for parent PID $parent_pid with command name $command_name."
    exit 1
else
    echo $latest_pid
fi
