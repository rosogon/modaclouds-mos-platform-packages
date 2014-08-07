#!/bin/bash

set -e -E -u -o pipefail -o noclobber -o noglob +o braceexpand || exit 1
trap 'printf "[ee] failed: %s\n" "${BASH_COMMAND}" >&2' ERR || exit 1

exec </dev/null >&2

MODACLOUDS_KNOWLEDGEBASE_HOME='@{package:root}'
FUSEKI_HOME='@{definitions:environment:FUSEKI_HOME}'
FUSEKI_CONF='@{definitions:environment:FUSEKI_CONF}'
RUBY_HOME='@{definitions:environment:RUBY_HOME}'

test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}"
test -n "${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}"

cd -- "${FUSEKI_HOME}"

exec "${RUBY_HOME}/bin/ruby" "${FUSEKI_HOME}/s-put" \
		"http://${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_IP}:${MODACLOUDS_KNOWLEDGEBASE_ENDPOINT_PORT}/modaclouds/kb/data" \
		default \
		"${FUSEKI_CONF}/ontology.ttl"

exit 1
