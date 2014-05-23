#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

export MODACLOUDS_KNOWLEDGEBASE_HOME="/opt/@{package_name}"
export FUSEKI_HOME="${MODACLOUDS_KNOWLEDGEBASE_HOME}/lib/jena-fuseki-@{jena_fuseki_version}"
export JAVA_HOME="/opt/mosaic-rt-jre-7"
export PATH="${JAVA_HOME}/bin:${PATH}"

test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_INITIALIZE}"

cd -- "${MODACLOUDS_KNOWLEDGEBASE_HOME}"

if test "${MODACLOUDS_KNOWLEDGEBASE_INITIALIZE}" == true ; then
(
	sleep 6s
	exec ./bin/@{package_name}--initialize
) &
fi

exec "${FUSEKI_HOME}/fuseki-server" \
		--port="${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}" \
		--config="${MODACLOUDS_KNOWLEDGEBASE_HOME}/etc/configuration.ttl" \
		--update

exit 1
