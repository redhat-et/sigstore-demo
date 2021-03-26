#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE}")/util.sh"

podman run --rm -v "${ROOT_DIR}":/project:Z docker.io/openpolicyagent/conftest:v0.23.0 test \
  --data "${MAINTAINERS}" -p "${MAINTAINERS_POLICY}" --parser json "${CERTIFICATE_COMMON_NAME}"
