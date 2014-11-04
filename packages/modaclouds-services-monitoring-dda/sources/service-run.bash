#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

if test "$( getent passwd -- mos-services | cut -f 3 -d : )" -ne "${UID}" ; then
	exec sudo -u mos-services -g mos-services -E -n -- "${0}" "${@}"
	exit 1
fi

exec </dev/null >&2

_variable_defaults=(
		
		_CSPARQL_HOME='@{definitions:environment:CSPARQL_HOME}'
		_CSPARQL_ENDPOINT_IP='@{definitions:environment:CSPARQL_ENDPOINT_IP}'
		_CSPARQL_ENDPOINT_PORT='@{definitions:environment:CSPARQL_ENDPOINT_PORT}'
		
		_JAVA_HOME='@{definitions:environment:JAVA_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_CSPARQL_ENDPOINT_IP="${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP:-${_CSPARQL_ENDPOINT_IP}}"
		_CSPARQL_ENDPOINT_PORT="${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT:-${_CSPARQL_ENDPOINT_PORT}}"
		
		_TMPDIR="${MODACLOUDS_MONITORING_DDA_TMPDIR:-${_TMPDIR}}"
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
printf '[ii]   * monitoring DDA endpoint: `http://%s:%s/`;\n' "${_CSPARQL_ENDPOINT_IP}" "${_CSPARQL_ENDPOINT_PORT}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;\n' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`;\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] starting monitoring DDA (CSPARQL)...\n' >&2
printf '[--]\n' >&2

exec \
	env \
			-i "${_environment[@]}" \
	"${_JAVA_HOME}/bin/java" \
			-jar "${_CSPARQL_HOME}/service.jar" \
			"${_CSPARQL_ENDPOINT_PORT}"

exit 1
