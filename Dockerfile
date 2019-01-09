FROM jboss/keycloak:4.5.0.Final

# Escalate privileges while we alter the image contents.
USER root

# TODO: Remove this when the keycloak version is upgraded!
# Monkey-patch the docker-entrypoint script to get the fix for this bug:
# https://issues.jboss.org/browse/KEYCLOAK-8459
# (master is already patched, but we don't want to use that and get an unexpected keycloak upgrade)
COPY ./tools/docker-entrypoint.sh /opt/jboss/tools/docker-entrypoint.sh
RUN chmod 0755 /opt/jboss/tools/docker-entrypoint.sh

# Add support for reading passwords from secrets files
COPY ./tools/docker-entrypoint-with-secrets.sh /opt/jboss/tools/docker-entrypoint-with-secrets.sh
RUN chmod 0755 /opt/jboss/tools/docker-entrypoint-with-secrets.sh
ENTRYPOINT ["/opt/jboss/tools/docker-entrypoint-with-secrets.sh"]
ENV KEYCLOAK_ENVIRONMENT=""
ENV DB_PASSWORD_FILE=""

# Install the custom ONACI theme
COPY ./theme /opt/jboss/keycloak/themes/onaci

# Install the onaci realm + default users configuration, and trigger KeyCloak
# to import this realm on startup if it is not already present.
# NOTE: use custom command arguments rather than the base-image's KEYCLOAK_IMPORT
# so that we have finer-grained control over how the import is handled.
# See: https://www.keycloak.org/docs/latest/server_admin/index.html#_export_import
COPY ./realms /opt/jboss/keycloak/realms
CMD [ "-Dkeycloak.migration.action=import", \
      "-Dkeycloak.migration.realmName=onaci", \
      "-Dkeycloak.migration.provider=dir", \
      "-Dkeycloak.migration.dir=/opt/jboss/keycloak/realms", \
      "-Dkeycloak.migration.strategy=IGNORE_EXISTING", \
      "-b", \
      "0.0.0.0"]

# add prometheus metrics ala https://github.com/feedhenry/keycloak-prometheus
# which uses https://github.com/larscheid-schmitzhermes/keycloak-monitoring-prometheus
# TODO: once i have some idea of what i'm doing, replace with https://github.com/aerogear/keycloak-metrics-spi ?
RUN sed -ie 's|<subsystem xmlns="urn:jboss:domain:keycloak-server:1.1">|<subsystem xmlns="urn:jboss:domain:keycloak-server:1.1"><spi name="eventsListener"><provider name="com.larscheidschmitzhermes:keycloak-monitoring-prometheus" enabled="true"><properties><property name="eventsDirectory" value="/opt/jboss/metrics"/></properties></provider></spi>|g' /opt/jboss/keycloak/standalone/configuration/standalone.xml
COPY artifacts/*.jar /opt/jboss/keycloak/providers/
RUN mkdir /opt/jboss/metrics

# Set the user back to the one the base-image expects.
USER 1000

