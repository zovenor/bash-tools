if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <parent_pid> <command_name> [ssh_host]"
    exit 1
fi

parent_pid=$1
command_name=$2
ssh_host=$3

if [ -z "$ssh_host" ]; then
    ps_command="ps -e -o pid,ppid,comm,etime"
else
    ps_command="ssh $ssh_host 'ps -e -o pid,ppid,comm,etime'"
fi

temp_file=$(mktemp)

find_child_processes() {
    local pid=$1
    eval "$ps_command" | awk -v ppid="$pid" '$2 == ppid {print $1, $3, $4}' >> "$temp_file"
    
    local child_pids=$(eval "$ps_command" | awk -v ppid="$pid" '$2 == ppid {print $1}')
    for child_pid in $child_pids; do
        find_child_processes "$child_pid"
    done
}

find_child_processes "$parent_pid"

sorted_file=$(mktemp)
awk '{ print $1, $2 " " $3 " " $4 }' "$temp_file" | sort -k2,2 -k3,3 -k4,4 > "$sorted_file"

latest_pid=$(grep -w "$command_name" "$sorted_file" | tail -n 1 | awk '{print $1}')

rm "$temp_file"
rm "$sorted_file"

if [ -z "$latest_pid" ]; then
    echo "No child processes found for parent PID $parent_pid with command name $command_name."
    exit 1
else
    echo $latest_pid
fi
