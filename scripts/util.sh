#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "$0")/.." ; pwd)"
MAINTAINERS="${MAINTAINERS:-maintainers}"
CERTIFICATE_COMMON_NAME="${CERTIFICATE_COMMON_NAME:-config/opa/certificate-common-name.json}"
MAINTAINERS_POLICY="${MAINTAINERS_POLICY:-config/opa/maintainers.rego}"

print-error-and-exit() {
  echo "$0: ERROR: ${1} not found."
  exit 1
}

if [[ ! -d ${ROOT_DIR}/${MAINTAINERS} ]]; then
  print-error-and-exit "MAINTAINERS=${ROOT_DIR}/${MAINTAINERS}"
elif [[ ! -f ${ROOT_DIR}/${CERTIFICATE_COMMON_NAME} ]]; then
  print-error-and-exit "CERTIFICATE_COMMON_NAME=${ROOT_DIR}/${CERTIFICATE_COMMON_NAME}"
elif [[ ! -f ${ROOT_DIR}/${MAINTAINERS_POLICY} ]]; then
  print-error-and-exit "MAINTAINERS_POLICY=${ROOT_DIR}/${MAINTAINERS_POLICY}"
fi

