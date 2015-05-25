
###########################
MODAClouds Service Template
###########################


Overview
########

In this template project you will find two sub-folders:

  * ``packaging``, which holds the mOS package builder descriptor and service execution script;
  * ``application``, which holds an example Java (Maven-based) application;


Java application binary distribution
####################################

For the Java application it is of notice the Maven POM file, which allows one to easily create the needed ``distribution.tar.gz`` file that holds both the JAR with dependencies and other required files.  In order to use it, one only needs to:

  * copy the ``maven-assembly-plugin`` configuration snippet in their own POM file;
  * copy the ``src/assembly`` folder;

Additionally this also enables one to include additional files into the distribution archive by simply placing them into the ``src/distribution`` folder.


Java application logging
########################

Also of notice in the Java application is the LogBack configuration that uses ``System.err`` instead of ``System.out``.



distribution.tar.gz
###################

The previous Maven POM will create an archive ending with ``tar.gz`` which should contain a single top folder named ``distribution``, and inside it a file ``service.jar``.  However for other languages, one can easily create a similar archive with other methods.

It should then be uploaded on the MODAClouds FTP, and then referenced with the url ``http://ftp.modaclouds.eu/...``.


service-run.bash
################

The ``service-run.bash`` file provided in the ``packaging`` folder is based on the other existing services run scripts and features the following:

  * it allows one to hard-code some variables during the packaging (see the ``package.json`` file) by simply using ``@{definitions:...}``;
  * it allows one to override at run-time some variables by using the matching ``MODACOUDS_...`` environment variables;
  * it takes care of creating a temporary workspace for each instance of the service;  (enabling thus to run multiple instances of the same service without interfering;)

To customize it, one only needs to touch three sections:

  * ``_variables_defaults``, which is an array of variables used within the script (usually to configure the service), whose values are either hard-coded or expanded at packaging time;  (the values such as ``@{definitions:...}`` are defined inside the ``package.json`` file);
  * ``_variables_overrides``, which usually holds the same variables as the previous section, but it tries to use the overriding ``MODACLOUDS_...`` environment variables, and if not present falling back to the hard-coded values;
  * ``_environment``, which is an array of environment variables to be exported to the service;

In short, if one needs a variable, it has to do the following:

  * add its value to the ``package.json`` definitions, by using the identifier ``environment:SERVICE_X_SOMETHING``;
  * add a line for it in the ``_variables_default`` array, by using the identifier ``_SERVICE_X_SOMETHING``;
  * add a line for it in the ``_variables_overrides`` array, by using the internal identifier ``_SERVICE_X_SOMETHING``, and the overriding environment variable ``MODACLOUDS_SERVICE_X_SOMETHING``;
  * add a line for it in the ``_environment`` array, by using the identifier ``MODACLOUDS_SERVICE_X_SOMETHING``;
  * (obviously all of these are optional, but the time spent in adding them, eases the testing and integration;)

Note that no other environment variables, except the ones explicitly added to the ``_environment`` array are exported further to the service, thus enabling a more robust and deterministic execution, not tainted by the testing environment.


Testing service-run.bash
########################

In order to ease the testing of the ``service-run.bash`` script, and because the default values for the various configuration variables are not yet expanded, one has to manually export all the proper values like below: ::

    env \
        MODACLOUDS_SERVICE_X_PATH="${PATH}" \
        MODACLOUDS_SERVICE_X_TMPDIR="/tmp/modaclouds-service-x" \
        MODACLOUDS_SERVICE_X_JAVA_HOME=/opt/java \
        MODACLOUDS_SERVICE_X_DISTRIBUTION=/tmp/modaclouds-service-x-distribution \
        MODACLOUDS_SERVICE_X_ENDPOINT_IP=127.0.0.1 \
        MODACLOUDS_SERVICE_X_ENDPOINT_PORT=8081 \
        MODACLOUDS_SERVICE_Y_ENDPOINT_IP=127.0.0.1 \
        MODACLOUDS_SERVICE_Y_ENDPOINT_PORT=8082 \
    ./service-run.bash

It is assumed that the contents of the ``distribution.tar.gz`` is already available at the path ``/tmp/modaclouds-service-x-distribution``.


Packaging
#########

To create the RPM, one only needs to execute the following: ::

    env mpb_debugging_enabled=true \
    python2.7 /.../mos-package-builder.py /.../modaclouds-service-x-package/packaging /tmp/modaclouds-service-x.rpm

The ``mos-package-builder.py`` script is found in the repository `<https://github.com/cipriancraciun/mosaic-mos-package-builder>`_, inside the ``sources`` sub-folder.

To install the RPM, one only needs to execute the following: ::

    zypper install /tmp/service-x.rpm

The present package descriptor makes the following assumptions:

  * the contents of the ``distribution.tar.gz`` will be extracted inside the ``/opt/modaclouds-service-x/lib/distribution`` folder, which will also be expanded into the ``service-run.bash`` script as ``@{definitions:environment:SERVICE_X_DISTRIBUTION}``;
  * the ``service-run.bash`` script will be put inside ``/opt/modaclouds-service-x/lib/scripts`` as ``run.bash``;
  * the ``service-run.bash`` script will also be symlinked as ``/opt/modaclouds-service-x/bin/modaclouds-service-x--run-service``;  (the superfluos ``modaclouds-service-x--run-service`` is needed to easily allow all ``bin`` folders to be put in ``${PATH}`` without having colisions, and allowing shell auto-completion;)
  * the run-time platform will always call ``/.../bin/modaclouds-service-x--run-service``;

Regarding the dependencies, inside the ``requires`` field one should not list those services to which the current one needs to connect to or use, but only those packages which provide actual run-time support for the service such as the Java JRE, or library, etc.



Links
#####

Further details can be found at the following links:

  * `<http://wiki.volution.ro/ModaClouds/Notes/ServiceDeployment/Supervised>`_;
  * `<http://wiki.volution.ro/ModaClouds/Notes/ComponentsBestPractices>`_;
  * `<http://wiki.volution.ro/Mosaic/Projects/MosPackageBuilder/Guide>`_;
