#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

if test "$( getent passwd -- mos-services | cut -f 3 -d : )" -ne "${UID}" ; then
	exec sudo -u mos-services -g mos-services -E -n -- "${0}" "${@}"
	exit 1
fi

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

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

cd -- "${_TMPDIR}/cwd"

printf '[--]\n' >&2
printf '[ii] parameters:\n' >&2
printf '[ii]   * knowledgebase endpoint: `http://%s:%s/`;\n' "${_FUSEKI_ENDPOINT_IP}" "${_FUSEKI_ENDPOINT_PORT}" >&2
printf '[ii]   * knowledgebase dataset: `%s`;\n' "${_FUSEKI_DATASET_PATH}" >&2
printf '[ii]   * knowledgebase installation: `%s`;\n' "${_FUSEKI_HOME}" >&2
printf '[ii]   * knowledgebase database: `%s`;\n' "${_FUSEKI_VAR}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;\n' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`;\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] starting knowledgebase (Fuseki)...\n' >&2
printf '[--]\n' >&2

exec \
	env \
			-i "${_environment[@]}" \
	"${_JAVA_HOME}/bin/java" \
			-jar "${_FUSEKI_HOME}/fuseki-server.jar" \
			--home="${_FUSEKI_HOME}" \
			--port="${_FUSEKI_ENDPOINT_PORT}" \
			--loc="${_FUSEKI_VAR}" \
			--update \
			-- \
			"${_FUSEKI_DATASET_PATH}"

exit 1
