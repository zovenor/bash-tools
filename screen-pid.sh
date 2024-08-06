if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <screen_name> [ssh_host]"
    exit 1
fi

screen_name=$1
ssh_host=$2

if [ -z "$ssh_host" ]; then
    screen_command="screen -ls"
else
    screen_command="ssh $ssh_host 'screen -ls'"
fi

screen_output=$(eval "$screen_command" 2>&1)


# Check if the eval command succeeded
if [[ "$screen_output" == *"ssh:"* ]]; then
    echo "SSH connection to $ssh_host failed."
    exit 1
fi

pid=$(echo "$screen_output" | awk -v name="$screen_name" '
    /Attached|Detached/ {
        split($1, arr, ".")
        if (arr[2] == name) print arr[1]
    }')

if [ -z "$pid" ]; then
    echo "No 'screen' process found with name $screen_name."
    exit 1
else
    echo $pid
fi
