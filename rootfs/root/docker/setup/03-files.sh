#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202606041215-git
# @@Author           :  CasjaysDev
# @@Contact          :  CasjaysDev <docker-admin@casjaysdev.pro>
# @@License          :  WTFPL
# @@ReadME           :
# @@Copyright        :  Copyright: (c) 2023 CasjaysDev
# @@Created          :  Mon Aug 28 06:48:42 PM EDT 2023
# @@File             :  03-files.sh
# @@Description      :  script to run files
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck shell=bash
# shellcheck disable=SC1001,SC1003,SC2001,SC2003,SC2016,SC2031,SC2090,SC2115,SC2120,SC2155,SC2199,SC2229,SC2317,SC2329
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set -o pipefail
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -x$DEBUGGER_OPTIONS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exitCode=0
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -d "/tmp/bin" ]; then
  \mkdir -p "/usr/local/bin"
  for bin in "/tmp/bin"/*; do
    name="${bin##*/}"
    echo "Installing $name to /usr/local/bin/$name"
    copy "$bin" "/usr/local/bin/$name"
    \chmod -f +x "/usr/local/bin/$name"
  done
fi
unset bin
if [ -d "/tmp/var" ]; then
  for var in "/tmp/var"/*; do
    name="${var##*/}"
    echo "Installing $var to /var/$name"
    if [ -d "$var" ]; then
      \mkdir -p "/var/$name"
      copy "$var/." "/var/$name/"
    else
      copy "$var" "/var/$name"
    fi
  done
fi
unset var
if [ -d "/tmp/etc" ]; then
  for config in "/tmp/etc"/*; do
    name="${config##*/}"
    echo "Installing $config to /etc/$name"
    if [ -d "$config" ]; then
      \mkdir -p "/etc/$name"
      copy "$config/." "/etc/$name/"
    else
      copy "$config" "/etc/$name"
    fi
  done
fi
unset config
if [ -d "/tmp/usr" ]; then
  for usrpath in "/tmp/usr"/*; do
    name="${usrpath##*/}"
    echo "Installing $usrpath to /usr/$name"
    if [ -d "$usrpath" ]; then
      \mkdir -p "/usr/$name"
      copy "$usrpath/." "/usr/$name/"
    else
      copy "$usrpath" "/usr/$name"
    fi
  done
fi
unset usrpath
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exitCode=$?
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $exitCode
# ex: ts=2 sw=2 et filetype=sh
