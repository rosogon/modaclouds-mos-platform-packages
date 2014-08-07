#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

MODACLOUDS_KNOWLEDGEBASE_HOME='@{package:root}'
FUSEKI_HOME='@{definitions:environment:FUSEKI_HOME}'
FUSEKI_CONF='@{definitions:environment:FUSEKI_CONF}'
JAVA_HOME='@{definitions:environment:JAVA_HOME}'

test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_INITIALIZE}"

if test "${MODACLOUDS_KNOWLEDGEBASE_INITIALIZE}" == true ; then
(
	sleep 6s
	exec "${MODACLOUDS_KNOWLEDGEBASE_HOME}/lib/scripts/initialize.bash"
) &
fi

export JAVA_HOME
export PATH="${JAVA_HOME}/bin:${PATH}"

cd -- "${FUSEKI_HOME}"

exec "${FUSEKI_HOME}/fuseki-server" \
		--port="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}" \
		--config="${FUSEKI_CONF}/configuration.ttl" \
		--update

exit 1
