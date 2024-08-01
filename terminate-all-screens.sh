terminate_screens() {
  local name="$1"
  local user_host="$2"
  local max_retries=5  
  local retry_delay=2 

  terminate() {
    if [ -n "$user_host" ]; then
      ssh "$user_host" "screen -ls | grep '\.$name' | awk '{print \$1}' | xargs -I{} screen -S {} -X quit"
    else
      screen -ls | grep "\.$name" | awk '{print $1}' | xargs -I{} screen -S {} -X quit
    fi
  }

  screens_exist() {
    if [ -n "$user_host" ]; then
      ssh "$user_host" "screen -ls | grep '\.$name'" > /dev/null 2>&1
    else
      screen -ls | grep "\.$name" > /dev/null 2>&1
    fi
  }

  local attempt=1
  while [ $attempt -le $max_retries ]; do
    terminate

    sleep "$retry_delay"

    if ! screens_exist; then
      return 0
    fi

    ((attempt++))
  done

  return 1
}

if [ -z "$1" ]; then
  echo "Usage: $0 <screen_name> [<user>@<host>]"
  exit 1
fi

SCREEN_NAME="$1"
USER_HOST="$2"

terminate_screens "$SCREEN_NAME" "$USER_HOST"
