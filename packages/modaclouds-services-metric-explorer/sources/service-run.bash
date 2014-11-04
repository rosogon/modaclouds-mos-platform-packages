#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

if test "$( getent passwd -- mos-services | cut -f 3 -d : )" -ne "${UID}" ; then
	exec sudo -u mos-services -g mos-services -E -n -- "${0}" "${@}"
	exit 1
fi

exec </dev/null >&2

_variable_defaults=(
		
		_GRAPHITE_ROOT='@{definitions:environment:GRAPHITE_ROOT}'
		_GRAPHITE_CONF_DIR='@{definitions:environment:GRAPHITE_CONF_DIR}'
		_GRAPHITE_STORAGE_DIR='@{definitions:environment:GRAPHITE_STORAGE_DIR}'
		
		_GRAPHITE_WEBAPP_ROOT='@{definitions:environment:GRAPHITE_WEBAPP_ROOT}'
		_GRAPHITE_WEBAPP_CONF_DIR='@{definitions:environment:GRAPHITE_WEBAPP_CONF_DIR}'
		_GRAPHITE_WEBAPP_CONTENT_DIR='@{definitions:environment:GRAPHITE_WEBAPP_CONTENT_DIR}'
		
		_GRAPHITE_QUERY_ENDPOINT_IP='@{definitions:environment:GRAPHITE_QUERY_ENDPOINT_IP}'
		_GRAPHITE_QUERY_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_QUERY_ENDPOINT_PORT}'
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP='@{definitions:environment:GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP}'
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT}'
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP='@{definitions:environment:GRAPHITE_LINE_RECEIVER_ENDPOINT_IP}'
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT}'
		_GRAPHITE_DASHBOARD_ENDPOINT_IP='@{definitions:environment:GRAPHITE_DASHBOARD_ENDPOINT_IP}'
		_GRAPHITE_DASHBOARD_ENDPOINT_PORT='@{definitions:environment:GRAPHITE_DASHBOARD_ENDPOINT_PORT}'
		
		_VIRTUALENV_HOME='@{definitions:environment:VIRTUALENV_HOME}'
		_PATH='@{definitions:environment:PATH}'
		_TMPDIR='@{definitions:environment:TMPDIR}'
)
declare "${_variable_defaults[@]}"

export PATH="${_PATH}"

_variable_overrides=(
		
		_GRAPHITE_CONF_DIR="${MODACLOUDS_METRIC_EXPLORER_GRAPHITE_CONF:-${_GRAPHITE_CONF_DIR}}"
		_GRAPHITE_STORAGE_DIR="${MODACLOUDS_METRIC_EXPLORER_GRAPHITE_VAR:-${_GRAPHITE_STORAGE_DIR}}"
		
		_GRAPHITE_WEBAPP_CONF_DIR="${MODACLOUDS_METRIC_EXPLORER_GRAPHITE_WEBAPP_CONF:-${_GRAPHITE_WEBAPP_CONF_DIR}}"
		
		_GRAPHITE_QUERY_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_QUERY_ENDPOINT_IP:-${_GRAPHITE_QUERY_ENDPOINT_IP}}"
		_GRAPHITE_QUERY_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_QUERY_ENDPOINT_PORT:-${_GRAPHITE_QUERY_ENDPOINT_PORT}}"
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_PICKLE_RECEIVER_ENDPOINT_IP:-${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP}}"
		_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_PICKLE_RECEIVER_ENDPOINT_PORT:-${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT}}"
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_LINE_RECEIVER_ENDPOINT_IP:-${_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP}}"
		_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_LINE_RECEIVER_ENDPOINT_PORT:-${_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT}}"
		_GRAPHITE_DASHBOARD_ENDPOINT_IP="${MODACLOUDS_METRIC_EXPLORER_DASHBOARD_ENDPOINT_IP:-${_GRAPHITE_DASHBOARD_ENDPOINT_IP}}"
		_GRAPHITE_DASHBOARD_ENDPOINT_PORT="${MODACLOUDS_METRIC_EXPLORER_DASHBOARD_ENDPOINT_PORT:-${_GRAPHITE_DASHBOARD_ENDPOINT_PORT}}"
		
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
	mkdir -- "${_GRAPHITE_STORAGE_DIR}/whisper"
	mkdir -- "${_GRAPHITE_STORAGE_DIR}/log"
	mkdir -- "${_GRAPHITE_STORAGE_DIR}/log/carbon"
	mkdir -- "${_GRAPHITE_STORAGE_DIR}/log/webapp"
	mkdir -- "${_GRAPHITE_STORAGE_DIR}/pid"
fi

if test -d "${_TMPDIR}/etc" ; then
	rm -R -- "${_TMPDIR}/etc"
fi
if test ! -e "${_TMPDIR}/etc" ; then
	mkdir -- "${_TMPDIR}/etc"
fi
cp -R -p -T -- "${_GRAPHITE_CONF_DIR}" "${_TMPDIR}/etc/carbon"
cp -R -p -T -- "${_GRAPHITE_WEBAPP_CONF_DIR}" "${_TMPDIR}/etc/webapp"

find "${_TMPDIR}/etc" -xdev -type f \
		-exec sed -r \
				-e 's!@\{GRAPHITE_ROOT\}!'"${_GRAPHITE_ROOT}"'!g' \
				-e 's!@\{GRAPHITE_CONF_DIR\}!'"${_TMPDIR}/etc/carbon"'!g' \
				-e 's!@\{GRAPHITE_STORAGE_DIR\}!'"${_GRAPHITE_STORAGE_DIR}"'!g' \
				-e 's!@\{GRAPHITE_WEBAPP_ROOT\}!'"${_GRAPHITE_WEBAPP_ROOT}"'!g' \
				-e 's!@\{GRAPHITE_WEBAPP_CONF_DIR\}!'"${_TMPDIR}/etc/webapp"'!g' \
				-e 's!@\{GRAPHITE_WEBAPP_CONTENT_DIR\}!'"${_GRAPHITE_WEBAPP_CONTENT_DIR}"'!g' \
				-e 's!@\{GRAPHITE_QUERY_ENDPOINT_IP\}!'"${_GRAPHITE_QUERY_ENDPOINT_IP}"'!g' \
				-e 's!@\{GRAPHITE_QUERY_ENDPOINT_PORT\}!'"${_GRAPHITE_QUERY_ENDPOINT_PORT}"'!g' \
				-e 's!@\{GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP\}!'"${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP}"'!g' \
				-e 's!@\{GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT\}!'"${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT}"'!g' \
				-e 's!@\{GRAPHITE_LINE_RECEIVER_ENDPOINT_IP\}!'"${_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP}"'!g' \
				-e 's!@\{GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT\}!'"${_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT}"'!g' \
				-e 's!@\{GRAPHITE_DASHBOARD_ENDPOINT_IP\}!'"${_GRAPHITE_DASHBOARD_ENDPOINT_IP}"'!g' \
				-e 's!@\{GRAPHITE_DASHBOARD_ENDPOINT_PORT\}!'"${_GRAPHITE_DASHBOARD_ENDPOINT_PORT}"'!g' \
				-i -- {} \;

_GRAPHITE_WEBAPP_KEY="$( uuidgen -r )"

_environment+=(
		GRAPHITE_ROOT="${_GRAPHITE_ROOT}"
		GRAPHITE_CONF_DIR="${_TMPDIR}/etc"
		GRAPHITE_STORAGE_DIR="${_GRAPHITE_STORAGE_DIR}"
		GRAPHITE_WEBAPP_ROOT="${_GRAPHITE_WEBAPP_ROOT}"
		GRAPHITE_WEBAPP_CONF_DIR="${_GRAPHITE_WEBAPP_CONF_DIR}"
		GRAPHITE_WEBAPP_CONTENT_DIR="${_GRAPHITE_WEBAPP_CONTENT_DIR}"
		GRAPHITE_WEBAPP_KEY="${_GRAPHITE_WEBAPP_KEY}"
)

if test -d "${_TMPDIR}/cwd" ; then
	rm -R -- "${_TMPDIR}/cwd"
fi
mkdir -- "${_TMPDIR}/cwd"

cd -- "${_TMPDIR}/cwd"

printf '[--]\n' >&2
printf '[ii] parameters:\n' >&2
printf '[ii]   * metric explorer dashboard endpoint: `http://%s:%s/`;\n' "${_GRAPHITE_DASHBOARD_ENDPOINT_IP}" "${_GRAPHITE_DASHBOARD_ENDPOINT_PORT}" >&2
printf '[ii]   * metric explorer query endpoint: `http://%s:%s/`;\n' "${_GRAPHITE_QUERY_ENDPOINT_IP}" "${_GRAPHITE_QUERY_ENDPOINT_PORT}" >&2
printf '[ii]   * metric explorer pickle receiver endpoint: `http://%s:%s/`;\n' "${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_IP}" "${_GRAPHITE_PICKLE_RECEIVER_ENDPOINT_PORT}" >&2
printf '[ii]   * metric explorer line receiver endpoint: `http://%s:%s/`;\n' "${_GRAPHITE_LINE_RECEIVER_ENDPOINT_IP}" "${_GRAPHITE_LINE_RECEIVER_ENDPOINT_PORT}" >&2
printf '[ii]   * environment:\n' >&2
for _variable in "${_environment[@]}" ; do
	printf '[ii]       * `%s`;\n' "${_variable}" >&2
done
printf '[ii]   * workding directory: `%s`;\n' "${PWD}" >&2
printf '[--]\n' >&2

printf '[ii] initializing database...\n' >&2
printf '[--]\n' >&2

env \
	env -i \
			"${_environment[@]}" \
	"${_VIRTUALENV_HOME}/bin/python" \
			-E -s \
			-O -B \
			-u \
			-- \
	"${_GRAPHITE_WEBAPP_ROOT}/graphite/manage.py" \
			syncdb \
			--noinput

(

sleep 12s

printf '[ii] starting metric explorer dashboard (Graphite)...\n' >&2
printf '[--]\n' >&2

exec \
	env -i \
			"${_environment[@]}" \
	"${_VIRTUALENV_HOME}/bin/python" \
			-E -s \
			-O -B \
			-u \
			-- \
	"${_VIRTUALENV_HOME}/bin/gunicorn" \
			--chdir "${_GRAPHITE_WEBAPP_ROOT}/graphite" \
			--worker-tmp-dir "${_TMPDIR}/tmp" \
			--workers 2 \
			--bind "${_GRAPHITE_DASHBOARD_ENDPOINT_IP}:${_GRAPHITE_DASHBOARD_ENDPOINT_PORT}" \
			--debug --log-file /dev/stderr \
			--env GRAPHITE_ROOT="${_GRAPHITE_ROOT}" \
			--env GRAPHITE_CONF_DIR="${_TMPDIR}/etc" \
			--env GRAPHITE_STORAGE_DIR="${_GRAPHITE_STORAGE_DIR}" \
			--env GRAPHITE_WEBAPP_ROOT="${_GRAPHITE_WEBAPP_ROOT}" \
			--env GRAPHITE_WEBAPP_CONF_DIR="${_GRAPHITE_WEBAPP_CONF_DIR}" \
			--env GRAPHITE_WEBAPP_CONTENT_DIR="${_GRAPHITE_WEBAPP_CONTENT_DIR}" \
			--env GRAPHITE_WEBAPP_KEY="${_GRAPHITE_WEBAPP_KEY}" \
			-- \
			graphite_wsgi:application

exit 1

) &

printf '[ii] starting metric explorer database (Carbon)...\n' >&2
printf '[--]\n' >&2

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
			--config="${_TMPDIR}/etc/carbon/carbon.conf" \
			--instance=default \
			--whitelist=/dev/null \
			--blacklist=/dev/null \
			--debug

exit 1
