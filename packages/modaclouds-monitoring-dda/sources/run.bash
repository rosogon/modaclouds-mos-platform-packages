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

cd -- "${MODACLOUDS_MONITORING_DDA_HOME}"

exec java -jar ./lib/rsp-services-csparql-0.4.3.jar

exit 1
