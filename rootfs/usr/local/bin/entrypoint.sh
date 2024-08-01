#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202408011327-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  WTFPL
# @@ReadME           :  entrypoint.sh --help
# @@Copyright        :  Copyright: (c) 2024 Jason Hempstead, Casjays Developments
# @@Created          :  Thursday, Aug 01, 2024 13:27 EDT
# @@File             :  entrypoint.sh
# @@Description      :  Entrypoint file for rarbg
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :  
# @@Resource         :  
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/docker-entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC2016
# shellcheck disable=SC2031
# shellcheck disable=SC2120
# shellcheck disable=SC2155
# shellcheck disable=SC2199
# shellcheck disable=SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup debugging - https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
[ -f "/config/.debug" ] && [ -z "$DEBUGGER_OPTIONS" ] && export DEBUGGER_OPTIONS="$(<"/config/.debug")" || DEBUGGER_OPTIONS="${DEBUGGER_OPTIONS:-}"
{ [ "$DEBUGGER" = "on" ] || [ -f "/config/.debug" ]; } && echo "Enabling debugging" && set -o pipefail -x$DEBUGGER_OPTIONS && export DEBUGGER="on" || set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PATH="/usr/local/etc/docker/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
SCRIPT_FILE="$0"
CONTAINER_NAME="rarbg"
SCRIPT_NAME="$(basename "$SCRIPT_FILE" 2>/dev/null)"
CONTAINER_NAME="${ENV_CONTAINER_NAME:-$CONTAINER_NAME}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# remove whitespaces from beginning argument
while :; do [ "$1" = " " ] && shift 1 || break; done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "$1" = "$SCRIPT_FILE" ] && shift 1
[ "$1" = "$SCRIPT_NAME" ] && shift 1
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import the functions file
if [ -f "/usr/local/etc/docker/functions/entrypoint.sh" ]; then
  . "/usr/local/etc/docker/functions/entrypoint.sh"
else
  echo "Can not load functions from /usr/local/etc/docker/functions/entrypoint.sh"
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
# Help message
--help)
  shift 1
  echo 'Docker container for '$CONTAINER_NAME''
  echo "Usage: $CONTAINER_NAME [cron exec start init shell certbot ssl procs ports healthcheck backup command]"
  echo ""
  exit 0
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create the default env files
__create_env_file "/config/env/default.sh" "/root/env.sh" &>/dev/null
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables from files
for set_env in "/root/env.sh" "/usr/local/etc/docker/env"/*.sh "/config/env"/*.sh; do
  [ -f "$set_env" ] && . "$set_env"
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define script variables
RUNAS_USER=""    # Default is root
SERVICE_UID=""   # set the user id
SERVICE_GID=""   # set the group id
SERVICE_USER=""  # execute command as another user
SERVICE_GROUP="" # Set the service group
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Primary server port- will be added to server ports
WEB_SERVER_PORT="" # port : 80,443
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Secondary ports
SERVER_PORTS="" # specifiy other ports
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Server directories
WWW_ROOT_DIR="" # set default web dir
DATABASE_DIR="" # set database dir
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Healthcheck variables
HEALTH_ENABLED="yes" # enable healthcheck [yes/no]
SERVICES_LIST="tini" # comma seperated list of processes for the healthcheck
HEALTH_ENDPOINTS=""  # url endpoints: [http://localhost/health,http://localhost/test]
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update path var
export PATH="${PATH:-}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Custom variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# show message
__run_message() {

  return
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
################## END OF CONFIGURATION #####################
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Startup variables
export INIT_DATE="${INIT_DATE:-$(date)}"
export CONTAINER_INIT="${CONTAINER_INIT:-no}"
export START_SERVICES="${START_SERVICES:-yes}"
export ENTRYPOINT_MESSAGE="${ENTRYPOINT_MESSAGE:-yes}"
export ENTRYPOINT_FIRST_RUN="${ENTRYPOINT_FIRST_RUN:-yes}"
export DATA_DIR_INITIALIZED="${DATA_DIR_INITIALIZED:-no}"
export CONFIG_DIR_INITIALIZED="${CONFIG_DIR_INITIALIZED:-no}"
export CONTAINER_NAME="${ENV_CONTAINER_NAME:-$CONTAINER_NAME}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# System
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LANG:-C.UTF-8}"
export TZ="${TZ:-${TIMEZONE:-America/New_York}}"
export HOSTNAME="${FULL_DOMAIN_NAME:-${SERVER_HOSTNAME:-$HOSTNAME}}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default directories
export SSL_DIR="${SSL_DIR:-/config/ssl}"
export SSL_CA="${SSL_CERT:-/config/ssl/ca.crt}"
export SSL_KEY="${SSL_KEY:-/config/ssl/localhost.pem}"
export SSL_CERT="${SSL_CERT:-/config/ssl/localhost.crt}"
export BACKUP_DIR="${BACKUP_DIR:-/data/backups}"
export LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-/usr/local/bin}"
export DEFAULT_DATA_DIR="${DEFAULT_DATA_DIR:-/usr/local/share/template-files/data}"
export DEFAULT_CONF_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/config}"
export DEFAULT_TEMPLATE_DIR="${DEFAULT_TEMPLATE_DIR:-/usr/local/share/template-files/defaults}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional
export PHP_INI_DIR="${PHP_INI_DIR:-$(__find_php_ini)}"
export PHP_BIN_DIR="${PHP_BIN_DIR:-$(__find_php_bin)}"
export HTTPD_CONFIG_FILE="${HTTPD_CONFIG_FILE:-$(__find_httpd_conf)}"
export NGINX_CONFIG_FILE="${NGINX_CONFIG_FILE:-$(__find_nginx_conf)}"
export MYSQL_CONFIG_FILE="${MYSQL_CONFIG_FILE:-$(__find_mysql_conf)}"
export PGSQL_CONFIG_FILE="${PGSQL_CONFIG_FILE:-$(__find_pgsql_conf)}"
export MONGODB_CONFIG_FILE="${MONGODB_CONFIG_FILE:-$(__find_mongodb_conf)}"
export ENTRYPOINT_PID_FILE="${ENTRYPOINT_PID_FILE:-/run/init.d/entrypoint.pid}"
export ENTRYPOINT_INIT_FILE="${ENTRYPOINT_INIT_FILE:-/config/.entrypoint.done}"
export ENTRYPOINT_DATA_INIT_FILE="${ENTRYPOINT_DATA_INIT_FILE:-/data/.docker_has_run}"
export ENTRYPOINT_CONFIG_INIT_FILE="${ENTRYPOINT_CONFIG_INIT_FILE:-/config/.docker_has_run}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$ENTRYPOINT_PID_FILE" ] || [ -f "$ENTRYPOINT_INIT_FILE" ]; then
  START_SERVICES="no" ENTRYPOINT_MESSAGE="no" ENTRYPOINT_FIRST_RUN="no"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# variables based on env/files
[ -f "/config/enable/ssl" ] && SSL_ENABLED="yes"
[ -f "/config/enable/ssh" ] && SSH_ENABLED="yes"
[ "$WEB_SERVER_PORT" = "443" ] && SSL_ENABLED="yes"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# export variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# is already Initialized
[ -f "$ENTRYPOINT_DATA_INIT_FILE" ] && DATA_DIR_INITIALIZED="yes" || DATA_DIR_INITIALIZED="no"
[ -f "$ENTRYPOINT_CONFIG_INIT_FILE" ] && CONFIG_DIR_INITIALIZED="yes" || CONFIG_DIR_INITIALIZED="no"
{ [ -f "$ENTRYPOINT_PID_FILE" ] || [ -f "$ENTRYPOINT_INIT_FILE" ]; } && ENTRYPOINT_FIRST_RUN="no" || ENTRYPOINT_FIRST_RUN="yes"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# clean ENV_PORTS variables
ENV_PORTS="${ENV_PORTS//,/ }"  #
ENV_PORTS="${ENV_PORTS//\/*/}" #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# clean SERVER_PORTS variables
SERVER_PORTS="${SERVER_PORTS//,/ }"  #
SERVER_PORTS="${SERVER_PORTS//\/*/}" #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# clean WEB_SERVER_PORTS variables
WEB_SERVER_PORTS="${WEB_SERVER_PORT//\/*/}"                             #
WEB_SERVER_PORTS="${WEB_SERVER_PORTS//\/*/}"                            #
WEB_SERVER_PORTS="${WEB_SERVER_PORT//,/ } ${ENV_WEB_SERVER_PORTS//,/ }" #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# rewrite and merge variables
ENV_PORTS="$(__format_variables "$ENV_PORTS" || false)"
WEB_SERVER_PORTS="$(__format_variables "$WEB_SERVER_PORTS" || false)"
ENV_PORTS="$(__format_variables "$SERVER_PORTS" "$WEB_SERVER_PORTS" "$ENV_PORTS" "$SERVER_PORTS" || false)"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
HEALTH_ENDPOINTS="${HEALTH_ENDPOINTS//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create required directories
mkdir -p "/run"
mkdir -p "/tmp"
mkdir -p "/root"
mkdir -p "/var/run"
mkdir -p "/var/tmp"
mkdir -p "/run/cron"
mkdir -p "/data/logs"
mkdir -p "/run/init.d"
mkdir -p "/config/enable"
mkdir -p "/config/secure"
mkdir -p "/usr/local/etc/docker/exec"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create required files
touch "/data/logs/start.log"
touch "/data/logs/entrypoint.log"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# fix permissions
chmod -f 777 "/run"
chmod -f 777 "/tmp"
chmod -f 700 "/root"
chmod -f 777 "/var/run"
chmod -f 777 "/var/tmp"
chmod -f 777 "/run/cron"
chmod -f 777 "/data/logs"
chmod -f 777 "/run/init.d"
chmod -f 777 "/config/enable"
chmod -f 777 "/config/secure"
chmod -f 777 "/data/logs/entrypoint.log"
chmod -f 777 "/usr/local/etc/docker/exec"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets ensure everyone can write to std*
[ -f "/dev/stdin" ] && chmod -f 777 "/dev/stdin"
[ -f "/dev/stderr" ] && chmod -f 777 "/dev/stderr"
[ -f "/dev/stdout" ] && chmod -f 777 "/dev/stdout"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cat <<EOF | tee /etc/profile.d/locales.shadow /etc/profile.d/locales.sh >/dev/null
export LANG="\${LANG:-C.UTF-8}"
export LC_ALL="\${LANG:-C.UTF-8}"
export TZ="\${TZ:-\${TIMEZONE:-America/New_York}}"
EOF
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create the backup dir
[ -n "$BACKUP_DIR" ] && { [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$ENTRYPOINT_FIRST_RUN" != "no" ]; then
  # Show start message
  if [ "$CONFIG_DIR_INITIALIZED" = "no" ] || [ "$DATA_DIR_INITIALIZED" = "no" ]; then
    [ "$ENTRYPOINT_MESSAGE" = "yes" ] && echo "Executing entrypoint script for rarbg"
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Set reusable variables
  { { [ -w "/etc" ] && [ ! -e "/etc/hosts" ]; } || [ -w "/etc/hosts" ]; } && UPDATE_FILE_HOSTS="yes"
  { { [ -w "/etc" ] && [ ! -e "/etc/timezone" ]; } || [ -w "/etc/timezone" ]; } && UPDATE_FILE_TZ="yes"
  { { [ -w "/etc" ] && [ ! -e "/etc/resolv.conf" ]; } || [ -w "/etc/resolv.conf" ]; } && UPDATE_FILE_RESOLV="yes"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Set timezone
  [ -n "$TZ" ] && [ "$UPDATE_FILE_TZ" = "yes" ] && echo "$TZ" >"/etc/timezone"
  [ -f "/usr/share/zoneinfo/$TZ" ] && [ "$UPDATE_FILE_TZ" = "yes" ] && ln -sf "/usr/share/zoneinfo/$TZ" "/etc/localtime"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # if ipv6 add it to /etc/hosts
  if [ "$UPDATE_FILE_HOSTS" = "yes" ]; then
    echo "# known hostname mappings" >"/etc/hosts"
    if [ -n "$(ip a 2>/dev/null | grep 'inet6.*::' || ifconfig 2>/dev/null | grep 'inet6.*::')" ]; then
      __printf_space "40" "::1" "localhost" >>"/etc/hosts"
      __printf_space "40" "127.0.0.1" "localhost" >>"/etc/hosts"
    else
      __printf_space "40" "127.0.0.1" "localhost" >>"/etc/hosts"
    fi
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # add .home domain
  if [ "$UPDATE_FILE_HOSTS" = "yes" ] && [ -n "$HOSTNAME" ]; then
    __grep_test " $HOSTNAME" "/etc/hosts" || __printf_space "40" "${CONTAINER_IP4_ADDRESS:-127.0.0.1}" "$HOSTNAME" >>"/etc/hosts"
    __grep_test " ${HOSTNAME%%.*}.home" "/etc/hosts" || __printf_space "40" "${CONTAINER_IP4_ADDRESS:-127.0.0.1}" "${HOSTNAME%%.*}.home" >>"/etc/hosts"
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # add domainname
  if [ "$UPDATE_FILE_HOSTS" = "yes" ] && [ "$DOMAINNAME" != "home" ] && [ -n "$DOMAINNAME" ] && [ "$HOSTNAME.$DOMAINNAME" != "$DOMAINNAME" ]; then
    __grep_test " ${HOSTNAME%%.*}.$DOMAINNAME" "/etc/hosts" || __printf_space "40" "${CONTAINER_IP4_ADDRESS:-127.0.0.1}" "${HOSTNAME%%.*}.$DOMAINNAME" >>"/etc/hosts"
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Set containers hostname
  [ -n "$HOSTNAME" ] && [ "$UPDATE_FILE_HOSTS" = "yes" ] && echo "$HOSTNAME" >"/etc/hostname"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Set containers hostname with domain
  # [ -n "$DOMAINNAME" ] && [ "$UPDATE_FILE_HOSTS" = "yes" ] && echo "$HOSTNAME.$DOMAINNAME" >"/etc/hostname"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if [ -f "/etc/hostname" ]; then
    [ -n "$(type -P hostname)" ] && hostname -F "/etc/hostname" &>/dev/null || HOSTNAME="$(<"/etc/hostname")"
    export HOSTNAME
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # import hosts file into container
  [ -f "/usr/local/etc/hosts" ] && [ "$UPDATE_FILE_HOSTS" = "yes" ] && cat "/usr/local/etc/hosts" | grep -vF "$HOSTNAME" >>"/etc/hosts"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # import resolv.conf file into container
  [ "$CUSTOM_DNS" != "yes" ] && [ -f "/usr/local/etc/resolv.conf" ] && [ "$UPDATE_FILE_RESOLV" = "yes" ] && cat "/usr/local/etc/resolv.conf" >"/etc/resolv.conf"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if [ -d "/usr/local/etc/skel" ]; then
    cp -Rf "/usr/local/etc/skel/." "$HOME/"
  fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete any .gitkeep files
[ -d "/data" ] && rm -Rf "/data/.gitkeep" "/data"/*/*.gitkeep
[ -d "/config" ] && rm -Rf "/config/.gitkeep" "/config"/*/*.gitkeep
[ -f "/usr/local/bin/.gitkeep" ] && rm -Rf "/usr/local/bin/.gitkeep"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup bin directory - /config/bin > /usr/local/bin
__initialize_custom_bin_dir
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy default system configs - /usr/local/share/template-files/defaults > /config/
__initialize_default_templates
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy custom config files - /usr/local/share/template-files/config > /config/
__initialize_config_dir
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy custom data files - /usr/local/share/template-files/data > /data/
__initialize_data_dir
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__initialize_ssl_certs
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$ENTRYPOINT_PID_FILE" ] || [ -f "$ENTRYPOINT_INIT_FILE" ]; then
  START_SERVICES="no"
  ENTRYPOINT_MESSAGE="no"
  ENTRYPOINT_FIRST_RUN="no"
  touch "$ENTRYPOINT_PID_FILE"
elif [ -d "/config" ]; then
  echo "$$" >"$ENTRYPOINT_PID_FILE"
  echo "Initialized on: $INIT_DATE" >"$ENTRYPOINT_INIT_FILE"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if this is a new container
if [ -f "$ENTRYPOINT_DATA_INIT_FILE" ]; then
  DATA_DIR_INITIALIZED="yes"
elif [ -d "/data" ]; then
  echo "Initialized on: $INIT_DATE" >"$ENTRYPOINT_DATA_INIT_FILE"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$ENTRYPOINT_CONFIG_INIT_FILE" ]; then
  CONFIG_DIR_INITIALIZED="yes"
elif [ -d "/config" ]; then
  echo "Initialized on: $INIT_DATE" >"$ENTRYPOINT_CONFIG_INIT_FILE"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$ENTRYPOINT_FIRST_RUN" != "no" ]; then
  # setup the smtp server
  __setup_mta
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# if no pid assume container restart
[ -f "$ENTRYPOINT_PID_FILE" ] && [ -f "/run/__start_init_scripts.pid" ] || START_SERVICES="yes"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "$ENTRYPOINT_MESSAGE" = "yes" ] && __printf_space "40" "Container ip address is:" "$CONTAINER_IP4_ADDRESS"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show configured listing processes
if [ "$ENTRYPOINT_MESSAGE" = "yes" ] && [ -n "$ENV_PORTS" ]; then
  show_port=""
  for port in $ENV_PORTS; do [ -n "$port" ] && show_port+="$(printf '%s ' "${port// /}") "; done
  __printf_space "40" "The following ports are open:" "$show_port"
  unset port show_port
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# execute init script
if [ -f "/tmp/init" ]; then sh "/tmp/init"; fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show message
__run_message
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Just start services
START_SERVICES="${START_SERVICES:-SYSTEM_INIT}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Start all services if no pidfile
if [ "$START_SERVICES" = "yes" ] && [ "$1" != "backup" ] && [ "$1" != "healthcheck" ]; then
  [ "$1" = "start" ] && shift 1
  [ "$1" = "all" ] && shift 1
  [ "$1" = "init" ] && export CONTAINER_INIT="yes"
  echo "$$" >"/run/init.d/entrypoint.pid"
  __start_init_scripts "/usr/local/etc/docker/init.d"
  START_SERVICES="no"
  CONTAINER_INIT="${CONTAINER_INIT:-no}"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Begin options
case "$1" in
init)
  shift 1
  echo "Container has been Initialized"
  exit 0
  ;;

cron)
  shift 1
  __cron "$@" &
  exit
  ;;
# backup data and config dirs
backup)
  shift 1
  save="${1:-$BACKUP_DIR}"
  backupExit=0
  date="$(date '+%Y%m%d-%H%M')"
  file="$save/$date.tar.gz"
  echo "Backing up /data /config to $file"
  sleep 1
  tar cfvz "$file" --exclude="$save" "/data" "/config" || false
  backupExit=$?
  [ $backupExit -eq 0 ] && echo "Backed up /data /config has finished" || echo "Backup of /data /config has failed"
  exit $backupExit
  ;;
# Docker healthcheck
healthcheck)
  healthStatus=0
  services="${SERVICES_LIST:-$@}"
  healthEnabled="${HEALTH_ENABLED:-}"
  healthPorts="${WEB_SERVER_PORTS:-}"
  healthEndPoints="${HEALTH_ENDPOINTS:-}"
  healthMessage="Everything seems to be running"
  services="${services//,/ }"
  [ "$healthEnabled" = "yes" ] || exit 0
  for proc in $services; do
    if [ -n "$proc" ]; then
      if ! __pgrep "$proc"; then
        echo "$proc is not running" >&2
        healthStatus=$((healthStatus + 1))
      fi
    fi
  done
  for port in $ports; do
    if [ -n "$(type -P netstat)" ] && [ -n "$port" ]; then
      if ! netstat -taupln | grep -q ":$port "; then
        echo "$port isn't open" >&2
        healthStatus=$((healthStatus + 1))
      fi
    fi
  done
  for endpoint in $healthEndPoints; do
    if [ -n "$endpoint" ]; then
      if ! __curl "$endpoint"; then
        echo "Can not connect to $endpoint" >&2
        healthStatus=$((healthStatus + 1))
      fi
    fi
  done
  [ "$healthStatus" -eq 0 ] || healthMessage="Errors reported see: docker logs --follow $CONTAINER_NAME"
  [ -n "$healthMessage" ] && echo "$healthMessage"
  exit $healthStatus
  ;;
  # show open ports
ports)
  shift 1
  ports="$(__netstat -taupln | awk -F ' ' '{print $4}' | awk -F ':' '{print $2}' | sort --unique --version-sort | grep -v '^$' | grep '^' || echo '')"
  [ -n "$ports" ] && printf '%s\n%s\n' "The following are servers:" "$ports" | tr '\n' ' '
  exit $?
  ;;
  # show running processes
procs)
  shift 1
  ps="$(__ps axco command | grep -vE 'COMMAND|grep|ps' | sort -u || grep '^' || echo '')"
  [ -n "$ps" ] && printf '%s\n%s\n' "Found the following processes" "$ps" | tr '\n' ' '
  exit $?
  ;;
  # setup ssl
ssl)
  shift 1
  __create_ssl_cert
  exit $?
  ;;
# manage ssl certificate
certbot)
  shift 1
  CERT_BOT_ENABLED="yes"
  if [ "$1" = "create" ]; then
    shift 1
    __certbot "create"
  elif [ "$1" = "renew" ]; then
    shift 1
    __certbot "renew certonly --force-renew"
  else
    __exec_command "certbot" "$@"
  fi
  exit $?
  ;;
# Launch shell
*/bin/sh | */bin/bash | bash | sh | shell)
  shift 1
  __exec_command "${@:-/bin/bash -l}"
  exit $?
  ;;
# execute commands
exec)
  shift 1
  __exec_command "${@:-echo "No commands given"}"
  exit $?
  ;;
# show/start init scripts
start)
  shift 1
  export PATH="/usr/local/etc/docker/init.d:$PATH"
  if [ $# -eq 0 ]; then
    scripts="$(ls -A "/usr/local/etc/docker/init.d")"
    [ -n "$scripts" ] && echo "$scripts" || echo "No scripts found in: /usr/local/etc/docker/init.d"
    exit
  elif [ "$1" = "all" ]; then
    shift $#
    if [ "$START_SERVICES" = "yes" ]; then
      echo "$$" >"/run/init.d/entrypoint.pid"
      __start_init_scripts "/usr/local/etc/docker/init.d"
      __no_exit
    elif [ -f "/usr/local/etc/docker/init.d/$1" ]; then
      eval "/usr/local/etc/docker/init.d/$1" &
      __no_exit

    fi
  fi
  ;;
# Execute primary command
*)
  if [ $# -eq 0 ]; then
    if [ ! -f "/run/init.d/entrypoint.pid" ]; then
      echo "$$" >"/run/init.d/entrypoint.pid"
      [ "$START_SERVICES" = "no" ] && [ "$CONTAINER_INIT" = "yes" ] || __start_init_scripts "/usr/local/etc/docker/init.d"
    fi
    __no_exit
  else
    __exec_command "$@"
  fi
  exit $?
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end of entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ex: ts=2 sw=2 et filetype=sh
