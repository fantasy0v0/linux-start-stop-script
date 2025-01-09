#!/bin/bash
base=`pwd`
if [ -f "$base/.pid" ]; then
  pid=$(cat "$base/.pid")
else
  pid=''
fi

is_running() {
  if [ -z "$1" ]; then
    return 1
  fi

  if ps -p "$1" > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

start() {
  if is_running "$pid"; then
    echo "Process with ID $pid is running."
    exit 1
  fi
  shift
  app="$1"
  shift
  nohup "$app" "$@" > app.log 2> error.log &
  new_pid=$!
  echo $new_pid > "$base/.pid"
  echo "Process started with ID $new_pid"
}

stop() {
  if [ -z "$pid" ]; then
    rm -f "$base/.pid"
    echo "No process to stop."
    exit 1
  fi
  if ! is_running "$pid"; then
    rm -f "$base/.pid"
    echo "Process with ID $pid is not running."
    exit 1
  fi
  kill "$pid"
  while is_running "$pid"; do
    echo "Waiting for process $pid to stop..."
    sleep 1
  done
  rm -f "$base/.pid"
  echo "Process with ID $pid has been stopped."
}

case "$1" in
  start)
    start "$@"
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac