#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

_variable_defaults=(
		
		_GRAPHITE_ROOT='@{definitions:environment:GRAPHITE_ROOT}'
		_GRAPHITE_CONF_DIR='@{definitions:environment:GRAPHITE_CONF_DIR}'
		_GRAPHITE_STORAGE_DIR='@{definitions:environment:GRAPHITE_STORAGE_DIR}'
		
		_GRAPHITE_QUERY_ENDPOINT_IP='@{definitions:environment:GRAPHITE_QUERY_ENDPOINT_IP}'
		_GRAPHITE_QUERY_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_QUERY_ENDPOINT_PORT}'
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP='@{definitions:environment:GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP}'
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT}'
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP='@{definitions:environment:GRAPHITE_LINE_RECEIVER_ENDPOINT_IP}'
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT}'
		
		_VIRTUALENV_HOME='@{definitions:environment:VIRTUALENV_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_GRAPHITE_CONF_DIR="${MODACLOUDS_METRIC_EXPLORER_GRAPHITE_CONF:-${_GRAPHITE_CONF_DIR}}"
		_GRAPHITE_STORAGE_DIR="${MODACLOUDS_METRIC_EXPLORER_GRAPHITE_VAR:-${_GRAPHITE_STORAGE_DIR}}"
		
		_GRAPHITE_QUERY_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_QUERY_ENDPOINT_IP:-${_GRAPHITE_QUERY_ENDPOINT_IP}}"
		_GRAPHITE_QUERY_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_QUERY_ENDPOINT_PORT:-${_GRAPHITE_QUERY_ENDPOINT_PORT}}"
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_PICKLE_RECEIVER_ENDPOINT_IP:-${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP}}"
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_PICKLE_RECEIVER_ENDPOINT_PORT:-${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT}}"
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_LINE_RECEIVER_ENDPOINT_IP:-${_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP}}"
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_LINE_RECEIVER_ENDPOINT_PORT:-${_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT}}"
		
		_TMPDIR="${MODACLOUDS_METRIC_EXPLORER_TMPDIR:-${_TMPDIR}}"
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

if test ! -e "${_GRAPHITE_STORAGE_DIR}" ; then
	_GRAPHITE_STORAGE_DIR="${_TMPDIR}/var"
fi
if test ! -e "${_GRAPHITE_STORAGE_DIR}" ; then
	mkdir -- "${_GRAPHITE_STORAGE_DIR}"
fi

if test -d "${_TMPDIR}/etc" ; then
	rm -R -- "${_TMPDIR}/etc"
fi
cp -R -p -T -- "${_GRAPHITE_CONF_DIR}" "${_TMPDIR}/etc"

find "${_TMPDIR}/etc" -xdev -type f \
		-exec sed -r \
				-e 's!@\{GRAPHITE_ROOT\}!'"${_GRAPHITE_ROOT}"'!g' \
				-e 's!@\{GRAPHITE_CONF_DIR\}!'"${_TMPDIR}/etc"'!g' \
				-e 's!@\{GRAPHITE_STORAGE_DIR\}!'"${_GRAPHITE_STORAGE_DIR}"'!g' \
				-e 's!@\{GRAPHITE_QUERY_ENDPOINT_IP\}!'"${_GRAPHITE_QUERY_ENDPOINT_IP}"'!g' \
				-e 's!@\{GRAPHITE_QUERY_ENDPOINT_PORT\}!'"${_GRAPHITE_QUERY_ENDPOINT_PORT}"'!g' \
				-e 's!@\{GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP\}!'"${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP}"'!g' \
				-e 's!@\{GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT\}!'"${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT}"'!g' \
				-e 's!@\{GRAPHITE_LINE_RECEIVER_ENDPOINT_IP\}!'"${_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP}"'!g' \
				-e 's!@\{GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT\}!'"${_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT}"'!g' \
				-i -- {} \;

_environment+=(
		GRAPHITE_ROOT="${_GRAPHITE_ROOT}"
		GRAPHITE_CONF_DIR="${_TMPDIR}/etc"
		GRAPHITE_STORAGE_DIR="${_GRAPHITE_STORAGE_DIR}"
)

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
	"${_GRAPHITE_ROOT}/bin/carbon-cache.py" \
			start \
			--config="${_TMPDIR}/etc/carbon.conf" \
			--instance=default \
			--whitelist=/dev/null \
			--blacklist=/dev/null \
			--debug

exit 1

