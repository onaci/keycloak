#!/bin/bash

# Optionally override environment variables with values from secret or 
# config files. (The file locations are passed in as different environment variables)
if [ -n "${KEYCLOAK_ENVIRONMENT}" ] && [ -f "${KEYCLOAK_ENVIRONMENT}" ]; then
  source "${KEYCLOAK_ENVIRONMENT}"
fi

if [ -n "${DB_PASSWORD_FILE}" ] && [ -f "${DB_PASSWORD_FILE}" ]; then
  export DB_PASSWORD=$(cat "${DB_PASSWORD_FILE}" | tr '\n' ' ' | cut -d ' ' -f1)
fi

# Execute all the normal docker-entrypoint functionality
THIS_DIR=$( cd "$(dirname "${0}")" && pwd)
source "${THIS_DIR}/docker-entrypoint.sh"