#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

export MODACLOUDS_MONITORING_DDA_HOME="/opt/@{package_name}"
export JAVA_HOME="/opt/mosaic-rt-jre-7"
export PATH="${JAVA_HOME}/bin:${PATH}"

test -n "${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP}"
test -n "${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT}"

test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}"

cd -- "${MODACLOUDS_MONITORING_DDA_HOME}/lib/rsp-services-csparql-@{csparql_version}"

sed -r \
		-e "s#@\{csparql_ip\}#${MODACLOUDS_MONITORING_DDA_ENDPOINT_IP}#g" \
		-e "s#@\{csparql_port\}#${MODACLOUDS_MONITORING_DDA_ENDPOINT_PORT}#g" \
	>|./setup.properties \
	<./setup.properties.orig

exec java -jar ./rsp-services-csparql-@{csparql_version}.jar

exit 1
