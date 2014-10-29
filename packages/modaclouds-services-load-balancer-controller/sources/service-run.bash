#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

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

export PATH="${_PATH}"

_variable_overrides=(
		
		_LB_CONTROLLER_ENDPOINT_IP="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_IP:-${_LB_CONTROLLER_ENDPOINT_IP}}"
		_LB_CONTROLLER_ENDPOINT_PORT="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_PORT:-${_LB_CONTROLLER_ENDPOINT_PORT}}"
		
		_LB_GATEWAY_ENDPOINT_IP="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_IP:-${_LB_GATEWAY_ENDPOINT_IP}}"
		_LB_GATEWAY_ENDPOINT_PORT_MIN="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MIN:-${_LB_GATEWAY_ENDPOINT_PORT_MIN}}"
		_LB_GATEWAY_ENDPOINT_PORT_MAX="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MAX:-${_LB_GATEWAY_ENDPOINT_PORT_MAX}}"
		
		_TMPDIR="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_TMPDIR:-${_TMPDIR}}"
)
declare "${_variable_overrides[@]}"

_environment=(
		PATH="${_PATH}"
		TMPDIR="${_TMPDIR}/tmp"
		HOME="${_TMPDIR}/home"
		USER='modaclouds-services'
)

if test ! -e "${_TMPDIR}" ; then
	mkdir -- "${_TMPDIR}"
	mkdir -- "${_TMPDIR}/tmp"
	mkdir -- "${_TMPDIR}/home"
fi

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

cd -- "${_TMPDIR}/cwd"

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
