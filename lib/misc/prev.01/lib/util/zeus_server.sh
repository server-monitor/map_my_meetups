notify_done() {
  local regexp='[z]eus runner: server'
  while : ; do
    ps --user "$USER" ax | /bin/grep "$regexp" && break
    echo "Waiting for Zeus '$regexp'..."
    sleep 1
  done

  notify-send --expire-time=10000 "'$regexp' is up."
}

main_start_server() {
  local regexp='[z]eus slave: test_environment'
  while : ; do
    ps --user "$USER" ax | /bin/grep "$regexp" && break
    echo "Waiting for Zeus '$regexp' before launching server..."
    sleep 1
  done

  notify-send --expire-time=5000 "'$regexp' is up."
  zeus server -p ${ZSPORT-3001}
}

notify_done &
main_start_server "$@"
