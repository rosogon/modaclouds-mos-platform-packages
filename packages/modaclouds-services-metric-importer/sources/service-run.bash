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
		
		_IMPORTER_HOME='@{definitions:environment:IMPORTER_HOME}'
		_IMPORTER_ENDPOINT_IP='@{definitions:environment:IMPORTER_ENDPOINT_IP}'
		_IMPORTER_ENDPOINT_PORT='@{definitions:environment:IMPORTER_ENDPOINT_PORT}'
		
		_GRAPHITE_ENDPOINT_IP='@{definitions:environment:GRAPHITE_ENDPOINT_IP}'
		_GRAPHITE_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_ENDPOINT_PORT}'
		
		_JAVA_HOME='@{definitions:environment:JAVA_HOME}'
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
		
		_IMPORTER_ENDPOINT_IP="${MODACLOUDS_METRIC_IMPORTER_ENDPOINT_IP:-${_IMPORTER_ENDPOINT_IP}}"
		_IMPORTER_ENDPOINT_PORT="${MODACLOUDS_METRIC_IMPORTER_ENDPOINT_PORT:-${_IMPORTER_ENDPOINT_PORT}}"
		
		_GRAPHITE_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_LINE_RECEIVER_ENDPOINT_IP:-${_GRAPHITE_ENDPOINT_IP}}"
		_GRAPHITE_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_LINE_RECEIVER_ENDPOINT_PORT:-${_GRAPHITE_ENDPOINT_PORT}}"
		
		_TMPDIR="${MODACLOUDS_METRIC_IMPORTER_TMPDIR:-${_TMPDIR}/${_identifier}}"
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
printf '[ii]   * metric importer endpoint: `http://%s:%s/`;\n' "${_IMPORTER_ENDPOINT_IP}" "${_IMPORTER_ENDPOINT_PORT}" >&2
printf '[ii]   * metric explorer line receiver endpoint: `http://%s:%s/`;\n' "${_GRAPHITE_ENDPOINT_IP}" "${_GRAPHITE_ENDPOINT_PORT}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;\n' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`;\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] starting metric importer...\n' >&2
printf '[--]\n' >&2

exec \
	env -i \
			"${_environment[@]}" \
	"${_JAVA_HOME}/bin/java" \
			-jar "${_IMPORTER_HOME}/service.jar" \
			"${_GRAPHITE_ENDPOINT_IP}" \
			"${_GRAPHITE_ENDPOINT_PORT}" \
			"${_IMPORTER_ENDPOINT_IP}" \
			"${_IMPORTER_ENDPOINT_PORT}"

exit 1
