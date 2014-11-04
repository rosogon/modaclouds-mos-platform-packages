#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

_variable_defaults=(
		
		_LB_REASONER_HOME='@{definitions:environment:LB_REASONER_HOME}'
		_LB_REASONER_CONF='@{definitions:environment:LB_REASONER_CONF}'
		
		_LB_CONTROLLER_ENDPOINT_IP='@{definitions:environment:LB_CONTROLLER_ENDPOINT_IP}'
		_LB_CONTROLLER_ENDPOINT_PORT='@{definitions:environment:LB_CONTROLLER_ENDPOINT_PORT}'
		
		_LB_GATEWAY_ENDPOINT_IP='@{definitions:environment:LB_GATEWAY_ENDPOINT_IP}'
		_LB_GATEWAY_ENDPOINT_PORT_MIN='@{definitions:environment:LB_GATEWAY_ENDPOINT_PORT_MIN}'
		_LB_GATEWAY_ENDPOINT_PORT_MAX='@{definitions:environment:LB_GATEWAY_ENDPOINT_PORT_MAX}'
		
		_MCR_HOME='@{definitions:environment:MCR_HOME}'
		_JAVA_HOME='@{definitions:environment:JAVA_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_LB_REASONER_CONF="${MODACLOUDS_LOAD_BALANCER_REASONER_CONF:-${_LB_REASONER_CONF}}"
		
		_LB_CONTROLLER_ENDPOINT_IP="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_IP:-${_LB_CONTROLLER_ENDPOINT_IP}}"
		_LB_CONTROLLER_ENDPOINT_PORT="${MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_PORT:-${_LB_CONTROLLER_ENDPOINT_PORT}}"
		
		_LB_GATEWAY_ENDPOINT_IP="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_IP:-${_LB_GATEWAY_ENDPOINT_IP}}"
		_LB_GATEWAY_ENDPOINT_PORT_MIN="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MIN:-${_LB_GATEWAY_ENDPOINT_PORT_MIN}}"
		_LB_GATEWAY_ENDPOINT_PORT_MAX="${MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MAX:-${_LB_GATEWAY_ENDPOINT_PORT_MAX}}"
		
		_TMPDIR="${MODACLOUDS_LOAD_BALANCER_REASONER_TMPDIR:-${_TMPDIR}}"
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
cp -R -p -T -- "${_LB_REASONER_CONF}" "${_TMPDIR}/etc"

find "${_TMPDIR}/etc" -xdev -type f \
		-exec sed -r \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_REASONER_HOME\}!'"${_LB_REASONER_HOME}"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_REASONER_CONF\}!'"${_TMPDIR}/etc"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_REASONER_TMPDIR\}!'"${_TMPDIR}/tmp"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_IP\}!'"${_LB_CONTROLLER_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_CONTROLLER_ENDPOINT_PORT\}!'"${_LB_CONTROLLER_ENDPOINT_PORT}"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_IP\}!'"${_LB_GATEWAY_ENDPOINT_IP}"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MIN\}!'"${_LB_GATEWAY_ENDPOINT_PORT_MIN}"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_MAX\}!'"${_LB_GATEWAY_ENDPOINT_PORT_MAX}"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT\}!'"${_LB_GATEWAY_ENDPOINT_PORT_MAX}"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_0\}!'"$(( ${_LB_GATEWAY_ENDPOINT_PORT_MAX} + 0 ))"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_1\}!'"$(( ${_LB_GATEWAY_ENDPOINT_PORT_MAX} + 1 ))"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_2\}!'"$(( ${_LB_GATEWAY_ENDPOINT_PORT_MAX} + 2 ))"'!g' \
				-e 's!@\{MODACLOUDS_LOAD_BALANCER_GATEWAY_ENDPOINT_PORT_3\}!'"$(( ${_LB_GATEWAY_ENDPOINT_PORT_MAX} + 3 ))"'!g' \
				-i -- {} \;

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

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

ln -s -T -- "${_LB_REASONER_HOME}/lib" "${_TMPDIR}/cwd/lib"
#ln -s -T -- "${_TMPDIR}/etc/configuration_LB.xml" "${_TMPDIR}/cwd/configuration_LB.xml"

cd -- "${_TMPDIR}/cwd"

printf '[--]\n' >&2
printf '[ii] parameters:\n' >&2
printf '[ii]   * load-balancer controller endpoint: `http://%s:%s/`;\n' "${_LB_CONTROLLER_ENDPOINT_IP}" "${_LB_CONTROLLER_ENDPOINT_PORT}" >&2
printf '[ii]   * load-balancer gateway endpoint: `tcp:%s:(%s-%s)`;\n' "${_LB_GATEWAY_ENDPOINT_IP}" "${_LB_GATEWAY_ENDPOINT_PORT_MIN}" "${_LB_GATEWAY_ENDPOINT_PORT_MAX}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] starting load-balancer reasoner...' >&2
printf '[--]\n' >&2

exec \
	env -i \
			"${_environment[@]}" \
	"${_LB_REASONER_HOME}/main" \
			"${_TMPDIR}/etc/configuration_LB.xml"

exit 1
