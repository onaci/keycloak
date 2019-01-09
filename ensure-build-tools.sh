#!/bin/sh
#------------------------------------------------------------------------------
# Ensure the build_tools scripts and all their dependencies are available
# in expected locations.
#
# This is posix-compatible so it can be sourced from a GitLab before_script
# without needing to worry about execute permissions on this file.
#------------------------------------------------------------------------------
if [ -z "${TOOLS_DIR}" ]; then
  echo "ERROR: the TOOLS_DIR environment variable has not been defined"
  exit -1
fi
if [ -z "${BUILD_TOOLS_REPO}" ]; then
  echo "ERROR: the BUILD_TOOLS_REPO environment variable has not been defined"
  exit -1
fi
if [ ! -d "${TOOLS_DIR}" ]; then
  GIT=$(which git || :)
  if [ -z "${GIT}" ]; then
    echo "Installing git"
    if [ -f "/etc/os-release" ] && [ -n "$(grep Alpine /etc/os-release)" ]; then 
      apk --no-cache add git
    elif [ -f "/etc/os-release" ]; then
      echo "WARNING: Don't know how to install git! os-release:\n$(cat /etc/os-release)"
    else
      echo "WARNING: Don't know how to install git for the $(uname) kernel"
    fi
  fi
  echo "Cloning build tools from ${BUILD_TOOLS_REPO} to ${TOOLS_DIR}"
  mkdir -p "${TOOLS_DIR}"
  git clone "${BUILD_TOOLS_REPO}" "${TOOLS_DIR}"
  chmod u+x "${TOOLS_DIR}"/*.sh
else
  echo "Using existing build tools at ${TOOLS_DIR}"
fi

