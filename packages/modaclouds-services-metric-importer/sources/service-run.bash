#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

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

export PATH="${_PATH}"

_variable_overrides=(
		
		_IMPORTER_ENDPOINT_IP="${MODACLOUDS_METRIC_IMPORTER_ENDPOINT_IP:-${_IMPORTER_ENDPOINT_IP}}"
		_IMPORTER_ENDPOINT_PORT="${MODACLOUDS_METRIC_IMPORTER_ENDPOINT_PORT:-${_IMPORTER_ENDPOINT_PORT}}"
		
		_GRAPHITE_ENDPOINT_IP="${MODACLOUDS_MONITORING_GRAPHITE_ENDPOINT_IP:-${_GRAPHITE_ENDPOINT_IP}}"
		_GRAPHITE_ENDPOINT_PORT="${MODACLOUDS_MONITORING_GRAPHITE_ENDPOINT_PORT:-${_GRAPHITE_ENDPOINT_PORT}}"
		
		_TMPDIR="${MODACLOUDS_METRIC_IMPORTER_TMPDIR:-${_TMPDIR}}"
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
	"${_JAVA_HOME}/bin/java" \
			-jar "${_IMPORTER_HOME}/service.jar" \
			"${_GRAPHITE_ENDPOINT_IP}" \
			"${_GRAPHITE_ENDPOINT_PORT}" \
			"${_IMPORTER_ENDPOINT_IP}" \
			"${_IMPORTER_ENDPOINT_PORT}"

exit 1
