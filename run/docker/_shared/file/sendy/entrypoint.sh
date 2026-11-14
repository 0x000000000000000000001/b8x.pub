#!/bin/bash
set -e

# Sendy docker entrypoint to ensure environment is initialized.

# logging functions
write_log() {
  local type="$1"; shift
  printf '%s [%s] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "$type" "$*"
}
log_info() { write_log Info "$@" ; }
log_warn() { write_log Warn "$@" >&2 ; }
log_error() { write_log ERROR "$@" >&2 ; exit 1 ; }

apache2_check_config() {
  local toRun=( "$@" -t ) errors
  if ! errors="$("${toRun[@]}" 2>&1 >/dev/null)"; then
    log_error "Apache2 failed while attempting to check config
	command was: ${toRun[*]}
	$errors"
  else
    log_info "Apache2 runtime configurations: OK"
  fi
}

_apache2_want_help() {
  local arg
  for arg; do
    case "$arg" in 
      -'?'|-h|-v|-V|-l|-L|-t|-S|-M) return 0 ;;
    esac
  done
  return 1
}

_main() {
  log_info "Entrypoint script for Sendy Server started."

  # if command starts with an option, prepend php
  if [ "${1:0:1}" = '-' ]; then
    set -- php "$@"
  fi

  # skip setup if we are not running apache2
  if [ "$1" = 'apache2-foreground' ] && ! _apache2_want_help "$@"; then
    log_info "Initializing Sendy environment..."

    # Ensure uploads directory and permissions
    mkdir -p /var/www/html/uploads/csvs
    chmod -R 777 /var/www/html/uploads
    chown -R www-data:www-data /var/www/html/uploads
    
    # Ensure apache config syntax is correct.
    apache2_check_config "$@"
    
    log_info "Starting Apache2"
    
    # Start cron
    env | grep -v 'no_proxy' > /etc/environment
    cron -f &
    log_info "Starting cron"
    exec "$@"
  else
    log_info "Command-line override. Executing: $@"
    exec "$@"
  fi
}

_main "$@"
