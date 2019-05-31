#!/bin/sh
set -o errexit
set -o nounset
set -o noclobber

## Load shared configuration, env, etc
set -a
. /etc/eduldap/lib/common
set +a
. /etc/eduldap/lib/info_mode
. /etc/eduldap/lib/init_mode
. /etc/eduldap/lib/server_mode
. /etc/eduldap/lib/reset_mode

default_mode=server
mode=${1:-$default_mode}

echo_envmode

if [[ $mode == server ]]; then

  [ $RESET == "true" ] && reset_mode
  [ $AUTO_INIT == "true" ] && init_mode

  server_mode

elif [[ $mode == info ]] ; then

   info_mode

elif [[ $mode == init ]] ; then

   init_mode

elif [[ $mode == reset ]] ; then

   reset_mode


elif [[ $mode == shell ]] ; then

  bin/sh;

elif [[ $mode == help ]] ; then

  echo
  echo "EduLDAP is a tool to build and run OpenLDAP directory services"
  echo "The eduldap script has the following modes:"
  echo
  echo "  eduldap - runs with the default mode '${default_mode}'"
  echo "  eduldap server - runs and initialises an OpenLDAP service"
  echo "  eduldap info   - lists available options in the image"
  echo "  eduldap init   - initialises a new container from the image"
  echo
  echo "  eduldap help - shows this help"
  echo
  exit

else
  echo "Invalid mode '${mode}'"
  exit
fi
