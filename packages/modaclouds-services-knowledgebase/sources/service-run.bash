#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

_variable_defaults=(
		
		_FUSEKI_HOME='@{definitions:environment:FUSEKI_HOME}'
		_FUSEKI_CONF='@{definitions:environment:FUSEKI_CONF}'
		_FUSEKI_VAR='@{definitions:environment:FUSEKI_VAR}'
		_FUSEKI_ENDPOINT_IP='@{definitions:environment:FUSEKI_ENDPOINT_IP}'
		_FUSEKI_ENDPOINT_PORT='@{definitions:environment:FUSEKI_ENDPOINT_PORT}'
		_FUSEKI_DATASET_PATH='@{definitions:environment:FUSEKI_DATASET_PATH}'
		
		_JAVA_HOME='@{definitions:environment:JAVA_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_FUSEKI_CONF="${MODACLOUDS_KNOWLEDGEBASE_FUSEKI_CONF:-${_FUSEKI_CONF}}"
		_FUSEKI_VAR="${MODACLOUDS_KNOWLEDGEBASE_FUSEKI_VAR:-${_FUSEKI_VAR}}"
		_FUSEKI_ENDPOINT_IP="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP:-${_FUSEKI_ENDPOINT_IP}}"
		_FUSEKI_ENDPOINT_PORT="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT:-${_FUSEKI_ENDPOINT_PORT}}"
		_FUSEKI_DATASET_PATH="${MODACLOUDS_KNOWLEDGEBASE_DATASET_PATH:-${_FUSEKI_DATASET_PATH}}"
		
		_TMPDIR="${MODACLOUDS_KNOWLEDGEBASE_TMPDIR:-${_TMPDIR}}"
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

if test ! -e "${_FUSEKI_VAR}" ; then
	_FUSEKI_VAR="${_TMPDIR}/var"
fi
if test ! -e "${_FUSEKI_VAR}" ; then
	mkdir -- "${_FUSEKI_VAR}"
fi

if test -d "${_TMPDIR}/etc" ; then
	rm -R -- "${_TMPDIR}/etc"
fi
cp -R -p -T -- "${_FUSEKI_CONF}" "${_TMPDIR}/etc"

find "${_TMPDIR}/etc" -xdev -type f \
		-exec sed -r \
				-e 's!@\{FUSEKI_HOME\}!'"${_FUSEKI_HOME}"'!g' \
				-e 's!@\{FUSEKI_CONF\}!'"${_TMPDIR}/etc"'!g' \
				-e 's!@\{FUSEKI_VAR\}!'"${_FUSEKI_VAR}"'!g' \
				-e 's!@\{FUSEKI_TMPDIR\}!'"${_TMPDIR}/tmp"'!g' \
				-e 's!@\{FUSEKI_ENDPOINT_IP\}!'"${_FUSEKI_ENDPOINT_IP}"'!g' \
				-e 's!@\{FUSEKI_ENDPOINT_PORT\}!'"${_FUSEKI_ENDPOINT_PORT}"'!g' \
				-e 's!@\{FUSEKI_DATASET_PATH\}!'"${_FUSEKI_DATASET_PATH}"'!g' \
				-i -- {} \;

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

cd -- "${_TMPDIR}/cwd"

exec \
	env \
			-i "${_environment[@]}" \
	"${_JAVA_HOME}/bin/java" \
			-jar "${_FUSEKI_HOME}/fuseki-server.jar" \
			--home="${_FUSEKI_HOME}" \
			--config="${_TMPDIR}/etc/configuration.ttl" \
			--port="${_FUSEKI_ENDPOINT_PORT}" \
			--update

exit 1
