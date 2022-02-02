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
Joplin_id=$(id -u joplin)
Joplin_group_id=$(id -g joplin)

set -- /usr/sbin/gosu $user:$user "$@"
if [ $Current_id != $Joplin_id ]; then
  groupmod --gid "$Current_group_id" $user
  usermod --uid "$Current_id" $user
fi
if isCommand "$1"; then
  set -- /sbin/tini -- node dist/app.js "$@"
fi

exec "$@"