#!/bin/bash

## chunk::dd0589220f7c9bd3c2b62f4e1edc9b95::begin ##
set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

if test "$( getent passwd -- mos-services | cut -f 3 -d : )" -ne "${UID}" ; then
	exec sudo -u mos-services -g mos-services -E -n -- "${0}" "${@}"
	exit 1
fi

if ! test "${#}" -eq 0 ; then
	printf '[ii] invalid arguments; aborting!\n' >&2
	exit 1
fi

umask 0027

exec </dev/null >&2
## chunk::dd0589220f7c9bd3c2b62f4e1edc9b95::end ##

_variable_defaults=(
		
		_LB_CONTROLLER_HOME='@{definitions:environment:LB_CONTROLLER_HOME}'
		_LB_CONTROLLER_ENDPOINT_IP='@{definitions:environment:LB_CONTROLLER_ENDPOINT_IP}'
		_LB_CONTROLLER_ENDPOINT_PORT='@{definitions:environment:LB_CONTROLLER_ENDPOINT_PORT}'
		
		_LB_GATEWAY_ENDPOINT_IP='@{definitions:environment:LB_GATEWAY_ENDPOINT_IP}'
		_LB_GATEWAY_ENDPOINT_PORT_MIN='@{definitions:environment:LB_GATEWAY_ENDPOINT_PORT_MIN}'
		_LB_GATEWAY_ENDPOINT_PORT_MAX='@{definitions:environment:LB_GATEWAY_ENDPOINT_PORT_MAX}'
		
		_VIRTUALENV_HOME='@{definitions:environment:VIRTUALENV_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

## chunk::fdccb2b60ff605167433bb1c89bd0b84::begin ##
export PATH="${_PATH}"

_identifier="${modaclouds_service_identifier:-0000000000000000000000000000000000000000}"

if test -n "${modaclouds_service_temporary:-}" ; then
	_TMPDIR="${modaclouds_service_temporary:-}"
elif test -n "${modaclouds_temporary:-}" ; then
	_TMPDIR="${modaclouds_temporary}/services/${_identifier}"
else
	_TMPDIR="${_TMPDIR}/${_identifier}"
fi
## chunk::fdccb2b60ff605167433bb1c89bd0b84::end ##

_variable_overrides=(
		
		_LB_CONTROLLER_ENDPOINT_IP="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_IP:-${_LB_CONTROLLER_ENDPOINT_IP}}"
		_LB_CONTROLLER_ENDPOINT_PORT="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_PORT:-${_LB_CONTROLLER_ENDPOINT_PORT}}"
		
		_LB_GATEWAY_ENDPOINT_IP="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_IP:-${_LB_GATEWAY_ENDPOINT_IP}}"
		_LB_GATEWAY_ENDPOINT_PORT_MIN="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MIN:-${_LB_GATEWAY_ENDPOINT_PORT_MIN}}"
		_LB_GATEWAY_ENDPOINT_PORT_MAX="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MAX:-${_LB_GATEWAY_ENDPOINT_PORT_MAX}}"
		
		_TMPDIR="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_TMPDIR:-${_TMPDIR}}"
)
declare "${_variable_overrides[@]}"

## chunk::3a0efc2555cc97891ac1266f5065920a::begin ##
if test ! -e "${_TMPDIR}" ; then
	mkdir -p -- "${_TMPDIR}"
	mkdir -- "${_TMPDIR}/tmp"
	mkdir -- "${_TMPDIR}/home"
fi

exec {_lock}<"${_TMPDIR}"
if ! flock -x -n "${_lock}" ; then
	printf '[ee] failed to acquire lock; aborting!\n' >&2
	exit 1
fi

if test -d "${_TMPDIR}/cwd" ; then
	chmod -R u+w -- "${_TMPDIR}/cwd"
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

cd -- "${_TMPDIR}/cwd"

_environment=(
		PATH="${_PATH}"
		TMPDIR="${_TMPDIR}/tmp"
		HOME="${_TMPDIR}/home"
		USER='modaclouds-services'
)
## chunk::3a0efc2555cc97891ac1266f5065920a::end ##

printf '[--]\n' >&2
printf '[ii] parameters:\n' >&2
printf '[ii]   * load-balancer controller endpoint: `http://%s:%s/`;\n' "${_LB_CONTROLLER_ENDPOINT_IP}" "${_LB_CONTROLLER_ENDPOINT_PORT}" >&2
printf '[ii]   * load-balancer gateway endpoint: `tcp:%s:(%s-%s)`;\n' "${_LB_GATEWAY_ENDPOINT_IP}" "${_LB_GATEWAY_ENDPOINT_PORT_MIN}" "${_LB_GATEWAY_ENDPOINT_PORT_MAX}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;\n' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`;\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] starting load-balancer controller...\n' >&2
printf '[--]\n' >&2

exec \
	env -i \
			"${_environment[@]}" \
	"${_VIRTUALENV_HOME}/bin/python" \
			-E -s \
			-O -B \
			-u \
			-- \
			"${_LB_CONTROLLER_HOME}/api_1_0/pyprox.py" \
			"${_LB_CONTROLLER_ENDPOINT_IP}" \
			"${_LB_CONTROLLER_ENDPOINT_PORT}" \
			default

exit 1
