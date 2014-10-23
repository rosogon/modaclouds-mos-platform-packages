#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

_variable_defaults=(
		
		_SDA_WEKA_HOME='@{definitions:environment:SDA_WEKA_HOME}'
		_SDA_WEKA_CONF='@{definitions:environment:SDA_WEKA_CONF}'
		_SDA_WEKA_ENDPOINT_IP='@{definitions:environment:SDA_WEKA_ENDPOINT_IP}'
		_SDA_WEKA_ENDPOINT_PORT='@{definitions:environment:SDA_WEKA_ENDPOINT_PORT}'
		
		_DDA_ENDPOINT_IP='@{definitions:environment:DDA_ENDPOINT_IP}'
		_DDA_ENDPOINT_PORT='@{definitions:environment:DDA_ENDPOINT_PORT}'
		
		_KNOWLEDGEBASE_ENDPOINT_IP='@{definitions:environment:KNOWLEDGEBASE_ENDPOINT_IP}'
		_KNOWLEDGEBASE_ENDPOINT_PORT='@{definitions:environment:KNOWLEDGEBASE_ENDPOINT_PORT}'
		_KNOWLEDGEBASE_DATASET_PATH='@{definitions:environment:KNOWLEDGEBASE_DATASET_PATH}'
		
		_JAVA_HOME='@{definitions:environment:JAVA_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_SDA_WEKA_CONF="${MODACLOUDS_MONITORING_SDA_WEKA_CONF:-${_SDA_WEKA_CONF}}"
		_SDA_WEKA_ENDPOINT_IP="${MODACLOUDS_MONITORING_SDA_WEKA_ENDPOINT_IP:-${_SDA_WEKA_ENDPOINT_IP}}"
		_SDA_WEKA_ENDPOINT_PORT="${MODACLOUDS_MONITORING_SDA_WEKA_ENDPOINT_PORT:-${_SDA_WEKA_ENDPOINT_PORT}}"
		
		_DDA_ENDPOINT_IP="${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP:-${_DDA_ENDPOINT_IP}}"
		_DDA_ENDPOINT_PORT="${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT:-${_DDA_ENDPOINT_PORT}}"
		
		_KNOWLEDGEBASE_ENDPOINT_IP="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP:-${_KNOWLEDGEBASE_ENDPOINT_IP}}"
		_KNOWLEDGEBASE_ENDPOINT_PORT="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT:-${_KNOWLEDGEBASE_ENDPOINT_PORT}}"
		_KNOWLEDGEBASE_DATASET_PATH="${MODACLOUDS_KNOWLEDGEBASE_DATASET_PATH:-${_KNOWLEDGEBASE_DATASET_PATH}}"
		
		_TMPDIR="${MODACLOUDS_SDA_WEKA_TMPDIR:-${_TMPDIR}}"
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

if test -d "${_TMPDIR}/etc" ; then
	rm -R -- "${_TMPDIR}/etc"
fi
cp -R -p -T -- "${_SDA_WEKA_CONF}" "${_TMPDIR}/etc"

find "${_TMPDIR}/etc" -xdev -type f \
		-exec sed -r \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_WEKA_HOME\}!'"${_SDA_WEKA_HOME}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_WEKA_CONF\}!'"${_TMPDIR}/etc"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_WEKA_TMPDIR\}!'"${_TMPDIR}/tmp"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_WEKA_ENDPOINT_IP\}!'"${_SDA_WEKA_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_WEKA_ENDPOINT_PORT\}!'"${_SDA_WEKA_ENDPOINT_PORT}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_DDA_ENDPOINT_IP\}!'"${_DDA_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT\}!'"${_DDA_ENDPOINT_PORT}"'!g' \
				-e 's!@\{MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP\}!'"${_KNOWLEDGEBASE_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT\}!'"${_KNOWLEDGEBASE_ENDPOINT_PORT}"'!g' \
				-e 's!@\{MODACLOUDS_KNOWLEDGEBASE_DATASET_PATH\}!'"${_KNOWLEDGEBASE_DATASET_PATH}"'!g' \
				-i -- {} \;

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

cd -- "${_TMPDIR}/cwd"

exec \
	env -i \
			"${_environment[@]}" \
	"${_JAVA_HOME}/bin/java" \
			-jar "${_SDA_WEKA_HOME}/main.jar" \
			"${_SDA_WEKA_ENDPOINT_PORT}"

exit 1
