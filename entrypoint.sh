#!/usr/bin/env bash
set -Eeo pipefail

isCommand() {
  
  if [ "$1" = "sh" ]; then
    return 1
  elif [ "$1" = "bash" ]; then
    return 1 
  fi
}
if [[ ! -z "$PUID" ]]; then
  Current_id=$PUID
  if [[ ! -z "$PGID" ]]; then
    Current_group_id=$PGID
  else
    Current_group_id=$PUID
  fi
else
  Current_id=$(id -u)
  Current_group_id=$(id -g)
fi

APP_id=$(id -u USER)
APP_group_id=$(id -g USER)

if [ $Current_id != $APP_id ]; then
  groupmod -o -g "$Current_group_id" USER || return 1
  usermod -o -u "$Current_id" USER || return 1
fi

echo "
User uid:    $(id -u USER)
User gid:    $(id -g USER)
-------------------------------------
"

if [[ ! -z "$Path" ]] ; then
  mkdir -p $Path || :
  # allow the container to be started with `--user`
  if [ "$user" = '0' ]; then
    find "$Path" \! -user USER -exec chown USER '{}' +
  fi
fi

exec /usr/sbin/gosu USER:USER mkdir -f /home/USER/packages/server/logs

if [ "$Current_id" = "0" ]; then
  echo "Switching to dedicated user 'USER'"
  if isCommand "$1"; then
    set -- /usr/bin/tini -- /usr/sbin/gosu USER:USER "$@"
  fi
fi

exec /usr/bin/tini -- "$@"
