#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

_variable_defaults=(
		
		_SDA_MATLAB_HOME='@{definitions:environment:SDA_MATLAB_HOME}'
		_SDA_MATLAB_CONF='@{definitions:environment:SDA_MATLAB_CONF}'
		_SDA_MATLAB_ENDPOINT_IP='@{definitions:environment:SDA_MATLAB_ENDPOINT_IP}'
		_SDA_MATLAB_ENDPOINT_PORT='@{definitions:environment:SDA_MATLAB_ENDPOINT_PORT}'
		
		_DDA_ENDPOINT_IP='@{definitions:environment:DDA_ENDPOINT_IP}'
		_DDA_ENDPOINT_PORT='@{definitions:environment:DDA_ENDPOINT_PORT}'
		
		_KNOWLEDGEBASE_ENDPOINT_IP='@{definitions:environment:KNOWLEDGEBASE_ENDPOINT_IP}'
		_KNOWLEDGEBASE_ENDPOINT_PORT='@{definitions:environment:KNOWLEDGEBASE_ENDPOINT_PORT}'
		_KNOWLEDGEBASE_DATASET_PATH='@{definitions:environment:KNOWLEDGEBASE_DATASET_PATH}'
		_KNOWLEDGEBASE_SYNC_PERIOD='@{definitions:environment:KNOWLEDGEBASE_SYNC_PERIOD}'
		
		_MCR_HOME='@{definitions:environment:MCR_HOME}'
		_JAVA_HOME='@{definitions:environment:JAVA_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_SDA_MATLAB_CONF="${MODACLOUDS_MONITORING_SDA_MATLAB_CONF:-${_SDA_MATLAB_CONF}}"
		_SDA_MATLAB_ENDPOINT_IP="${MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_IP:-${_SDA_MATLAB_ENDPOINT_IP}}"
		_SDA_MATLAB_ENDPOINT_PORT="${MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_PORT:-${_SDA_MATLAB_ENDPOINT_PORT}}"
		
		_DDA_ENDPOINT_IP="${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP:-${_DDA_ENDPOINT_IP}}"
		_DDA_ENDPOINT_PORT="${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT:-${_DDA_ENDPOINT_PORT}}"
		
		_KNOWLEDGEBASE_ENDPOINT_IP="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP:-${_KNOWLEDGEBASE_ENDPOINT_IP}}"
		_KNOWLEDGEBASE_ENDPOINT_PORT="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT:-${_KNOWLEDGEBASE_ENDPOINT_PORT}}"
		_KNOWLEDGEBASE_DATASET_PATH="${MODACLOUDS_KNOWLEDGEBASE_DATASET_PATH:-${_KNOWLEDGEBASE_DATASET_PATH}}"
		_KNOWLEDGEBASE_SYNC_PERIOD="${MODACLOUDS_KNOWLEDGEBASE_SYNC_PERIOD:-${_KNOWLEDGEBASE_SYNC_PERIOD}}"
		
		_DEPLOYMENT_APP_ID="${MODACLOUDS_DEPLOYMENT_APP_ID:-__none__}"
		_DEPLOYMENT_VM_ID="${MODACLOUDS_DEPLOYMENT_VM_ID:-__none__}"
		
		_TMPDIR="${MODACLOUDS_MONITORING_SDA_MATLAB_TMPDIR:-${_TMPDIR}}"
)
declare "${_variable_overrides[@]}"

_environment=(
		PATH="${_PATH}"
		TMPDIR="${_TMPDIR}/tmp"
		HOME="${_TMPDIR}/home"
		USER='modaclouds-services'
)

_LD_LIBRARY_PATHS=(
		"${_MCR_HOME}/runtime/glnxa64"
		"${_MCR_HOME}/bin/glnxa64"
		"${_MCR_HOME}/sys/os/glnxa64"
		"${_MCR_HOME}/sys/java/jre/glnxa64/jre/lib/amd64"
		"${_MCR_HOME}/sys/java/jre/glnxa64/jre/lib/amd64/native_threads"
		"${_MCR_HOME}/sys/java/jre/glnxa64/jre/lib/amd64/server"
		"${_MCR_HOME}/sys/java/jre/glnxa64/jre/lib/amd64/client"
)
_LD_LIBRARY_PATH=""
for _LD_LIBRARY_PATH_COMP in "${_LD_LIBRARY_PATHS[@]}" ; do
	_LD_LIBRARY_PATH+=":${_LD_LIBRARY_PATH_COMP}"
done
_LD_LIBRARY_PATH="${_LD_LIBRARY_PATH#:}"

_environment+=(
		LD_LIBRARY_PATH="${_LD_LIBRARY_PATH}"
)

_XAPPLRESDIR="${_MCR_HOME}/X11/app-defaults" ;

_environment+=(
		XAPPLRESDIR="${_XAPPLRESDIR}"
)

if test ! -e "${_TMPDIR}" ; then
	mkdir -- "${_TMPDIR}"
	mkdir -- "${_TMPDIR}/tmp"
	mkdir -- "${_TMPDIR}/home"
fi

if test -d "${_TMPDIR}/etc" ; then
	rm -R -- "${_TMPDIR}/etc"
fi
cp -R -p -T -- "${_SDA_MATLAB_CONF}" "${_TMPDIR}/etc"

find "${_TMPDIR}/etc" -xdev -type f \
		-exec sed -r \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_MATLAB_HOME\}!'"${_SDA_MATLAB_HOME}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_MATLAB_CONF\}!'"${_TMPDIR}/etc"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_MATLAB_TMPDIR\}!'"${_TMPDIR}/tmp"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_IP\}!'"${_SDA_MATLAB_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_SDA_MATLAB_ENDPOINT_PORT\}!'"${_SDA_MATLAB_ENDPOINT_PORT}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_DDA_ENDPOINT_IP\}!'"${_DDA_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT\}!'"${_DDA_ENDPOINT_PORT}"'!g' \
				-e 's!@\{MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP\}!'"${_KNOWLEDGEBASE_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT\}!'"${_KNOWLEDGEBASE_ENDPOINT_PORT}"'!g' \
				-e 's!@\{MODACLOUDS_KNOWLEDGEBASE_DATASET_PATH\}!'"${_KNOWLEDGEBASE_DATASET_PATH}"'!g' \
				-e 's!@\{MODACLOUDS_KNOWLEDGEBASE_SYNC_PERIOD\}!'"${_KNOWLEDGEBASE_SYNC_PERIOD}"'!g' \
				-e 's!@\{MODACLOUDS_DEPLOYMENT_APP_ID\}!'"${_DEPLOYMENT_APP_ID}"'!g' \
				-e 's!@\{MODACLOUDS_DEPLOYMENT_VM_ID\}!'"${_DEPLOYMENT_VM_ID}"'!g' \
				-i -- {} \;

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

ln -s -T -- "${_SDA_MATLAB_HOME}/lib" "${_TMPDIR}/cwd/lib"
ln -s -T -- "${_TMPDIR}/etc/config.properties" "${_TMPDIR}/cwd/config.properties"

cd -- "${_TMPDIR}/cwd"

exec \
	env -i \
			"${_environment[@]}" \
	"${_SDA_MATLAB_HOME}/main" \
			kb \
			"${_SDA_MATLAB_ENDPOINT_PORT}"

exit 1
