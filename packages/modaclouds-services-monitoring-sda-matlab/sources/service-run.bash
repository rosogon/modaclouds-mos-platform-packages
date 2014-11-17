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

if test -d "${_TMPDIR}/etc" ; then
	chmod -R u+w -- "${_TMPDIR}/etc"
	rm -R -- "${_TMPDIR}/etc"
fi
cp -R -p -T -- "${_SDA_MATLAB_CONF}" "${_TMPDIR}/etc"
chmod -R u+w -- "${_TMPDIR}/etc"

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

chmod -R u-w -- "${_TMPDIR}/etc"

ln -s -T -- "${_SDA_MATLAB_HOME}/lib" "${_TMPDIR}/cwd/lib"
ln -s -T -- "${_TMPDIR}/etc/config.properties" "${_TMPDIR}/cwd/config.properties"

printf '[--]\n' >&2
printf '[ii] parameters:\n' >&2
printf '[ii]   * monitoring SDA Matlab endpoint: `http://%s:%s/`;\n' "${_SDA_MATLAB_ENDPOINT_IP}" "${_SDA_MATLAB_ENDPOINT_PORT}" >&2
printf '[ii]   * monitoring DDA endpoint: `http://%s:%s/`;\n' "${_DDA_ENDPOINT_IP}" "${_DDA_ENDPOINT_PORT}" >&2
printf '[ii]   * knowledgebase endpoint: `http://%s:%s/`;\n' "${_KNOWLEDGEBASE_ENDPOINT_IP}" "${_KNOWLEDGEBASE_ENDPOINT_PORT}" >&2
printf '[ii]   * knowledgebase dataset: `%s`;\n' "${_KNOWLEDGEBASE_DATASET_PATH}" >&2
printf '[ii]   * knowledgebase sync-period: `%s`;\n' "${_KNOWLEDGEBASE_SYNC_PERIOD}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;\n' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`;\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] starting monitoring SDA Matlab...\n' >&2
printf '[--]\n' >&2

exec \
	env -i \
			"${_environment[@]}" \
	"${_SDA_MATLAB_HOME}/main" \
			kb \
			"${_SDA_MATLAB_ENDPOINT_PORT}"

exit 1
