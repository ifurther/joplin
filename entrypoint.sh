#!/bin/sh

isCommand() {
  
  if [ "$1" = "sh" ]; then
    return 1
  elif [ "$1" = "bash" ]; then
    return 1 
  fi
}

Current_id=$(id -u)
Current_group_id=$(id -g)
APP_id=$(id -u USER)
APP_group_id=$(id -g USER)

if [ $Current_id != $APP_id ]; then
  groupmod --gid $Current_group_id USER
  usermod --uid $Current_id USER
fi
if isCommand "$1"; then
  set -- /usr/sbin/gosu USER:USER /usr/bin/tini -- node dist/app.js "$@"
fi

exec "$@"