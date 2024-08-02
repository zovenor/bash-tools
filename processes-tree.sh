if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <pid> [ssh_host]"
    exit 1
fi

pid=$1
ssh_host=$2

if [ -z "$ssh_host" ]; then
    ps_command="ps -e -o pid,ppid,comm"
else
    ps_command="ssh $ssh_host 'ps -e -o pid,ppid,comm'"
fi

temp_file=$(mktemp)

find_process_tree() {
    local pid=$1
    eval "$ps_command" | awk -v ppid="$pid" '$2 == ppid {print $1, $2, $3}' >> "$temp_file"
    
    local child_pids=$(eval "$ps_command" | awk -v ppid="$pid" '$2 == ppid {print $1}')
    for child_pid in $child_pids; do
        find_process_tree "$child_pid"
    done
}

find_process_tree "$pid"

display_tree() {
    local pid=$1
    local indent=$2
    echo "${indent}PID: $pid"
    while read -r line; do
        local child_pid=$(echo "$line" | awk '{print $1}')
        local child_ppid=$(echo "$line" | awk '{print $2}')
        local child_comm=$(echo "$line" | awk '{print $3}')
        if [ "$child_ppid" -eq "$pid" ]; then
            display_tree "$child_pid" "$indent    "
        fi
    done < "$temp_file"
}

echo "Process tree for PID $pid:"
display_tree "$pid" ""

rm "$temp_file"
