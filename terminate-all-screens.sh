#!/bin/bash

# This script terminates all screen sessions with a specified name, locally or on a remote server via SSH

# Function to terminate screen sessions by name
terminate_screens() {
  local name="$1"
  local user_host="$2"

  if [ -n "$user_host" ]; then
    # Command to execute on remote server
    ssh "$user_host" "screen -ls | grep '\.$name' | awk '{print \$1}' | xargs -I{} screen -S {} -X quit"
  else
    # Command to execute locally
    screen -ls | grep "\.$name" | awk '{print $1}' | xargs -I{} screen -S {} -X quit
  fi
}

# Check if a screen name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <screen_name> [<user>@<host>]"
  exit 1
fi

SCREEN_NAME="$1"
USER_HOST="$2"

# Terminate the screens
terminate_screens "$SCREEN_NAME" "$USER_HOST"

echo "All screen sessions with the name '$SCREEN_NAME' have been terminated."
