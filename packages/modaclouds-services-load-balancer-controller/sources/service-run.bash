#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

if test "$( getent passwd -- mos-services | cut -f 3 -d : )" -ne "${UID}" ; then
	exec sudo -u mos-services -g mos-services -E -n -- "${0}" "${@}"
	exit 1
fi

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
