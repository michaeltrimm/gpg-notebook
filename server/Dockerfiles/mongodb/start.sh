#!/bin/bash
#
# @version @package_version@
# @author Michael A. Trimm
# @website https://github.com/michaeltrimm
#
#
set -e

if [ "${1:0:1}" = '-' ]; then
  set -- mongod "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'mongod' -a "$(id -u)" = '0' ]; then
  chown -R mongodb /data/configdb /data/db
  exec gosu mongodb "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'mongod' ]; then
  numa='numactl --interleave=all'
  if $numa true &> /dev/null; then
    set -- $numa "$@"
  fi
fi

exec "$@"