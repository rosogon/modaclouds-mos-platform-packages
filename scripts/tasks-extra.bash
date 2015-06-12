#!/dev/null

cat <<EOS

modaclouds-platform-core@package : mosaic-node-boot@package | mosaic-node-boot@publish

modaclouds-platform-core@publish :

modaclouds-services-fg-analyzer@package :
modaclouds-services-fg-local-db@package :
modaclouds-services-knowledgebase@package :
modaclouds-services-load-balancer-controller@package :
modaclouds-services-load-balancer-reasoner@package :
modaclouds-services-metric-explorer@package :
modaclouds-services-metric-importer@package :
modaclouds-services-models-at-runtime@package :
modaclouds-services-monitoring-dda@package :
modaclouds-services-monitoring-manager@package :
modaclouds-services-monitoring-sda-matlab@package :
modaclouds-services-monitoring-sda-weka@package :
modaclouds-services-sla-core@package :
modaclouds-tools-mdload@package :

modaclouds-services-fg-analyzer@publish :
modaclouds-services-fg-local-db@publish :
modaclouds-services-knowledgebase@publish :
modaclouds-services-load-balancer-controller@publish :
modaclouds-services-load-balancer-reasoner@publish :
modaclouds-services-metric-explorer@publish :
modaclouds-services-metric-importer@publish :
modaclouds-services-models-at-runtime@publish :
modaclouds-services-monitoring-dda@publish :
modaclouds-services-monitoring-manager@publish :
modaclouds-services-monitoring-sda-matlab@publish :
modaclouds-services-monitoring-sda-weka@publish :
modaclouds-services-sla-core@publish :
modaclouds-tools-mdload@publish :

EOS

exit 0
