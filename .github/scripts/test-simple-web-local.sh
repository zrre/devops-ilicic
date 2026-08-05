#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
IMAGE_NAME="${IMAGE_NAME:-simple-web:local}"
PLATFORM="${PLATFORM:-linux/amd64}"

WORK_DIR="$(mktemp -d)"
IMAGE_ARCHIVE="${WORK_DIR}/simple-web.tar"

cleanup() {
  rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command not found: $1" >&2
    exit 1
  fi
}

require_command trivy
require_command grype

cd "${ROOT_DIR}"

echo "========================================"
echo "OpenTofu formatting"
echo "========================================"
tofu fmt -check -recursive

echo
echo "========================================"
echo "Terragrunt formatting"
echo "========================================"
terragrunt hcl fmt --check

if command -v podman >/dev/null 2>&1; then
  CONTAINER_ENGINE="podman"

  echo
  echo "========================================"
  echo "Building ${IMAGE_NAME} with Podman"
  echo "Platform: ${PLATFORM}"
  echo "========================================"

  podman build \
    --pull=always \
    --no-cache \
    --platform "${PLATFORM}" \
    --tag "${IMAGE_NAME}" \
    --file docker/simple-web/Dockerfile \
    docker/simple-web

  echo
  echo "========================================"
  echo "Installed security-relevant packages"
  echo "========================================"

  podman run --rm \
    --user 0 \
    --entrypoint /bin/sh \
    "${IMAGE_NAME}" \
    -c 'apk list --installed 2>/dev/null | grep -E "^(c-ares|curl|libcurl|libexpat)-"'

  podman save \
    --format docker-archive \
    --output "${IMAGE_ARCHIVE}" \
    "${IMAGE_NAME}"
else
  require_command docker
  CONTAINER_ENGINE="docker"

  echo
  echo "========================================"
  echo "Building ${IMAGE_NAME} with Docker"
  echo "Platform: ${PLATFORM}"
  echo "========================================"

  docker build \
    --pull \
    --no-cache \
    --platform "${PLATFORM}" \
    --tag "${IMAGE_NAME}" \
    --file docker/simple-web/Dockerfile \
    docker/simple-web

  echo
  echo "========================================"
  echo "Installed security-relevant packages"
  echo "========================================"

  docker run --rm \
    --user 0 \
    --entrypoint /bin/sh \
    "${IMAGE_NAME}" \
    -c 'apk list --installed 2>/dev/null | grep -E "^(c-ares|curl|libcurl|libexpat)-"'

  docker save \
    --output "${IMAGE_ARCHIVE}" \
    "${IMAGE_NAME}"
fi

echo
echo "Container engine: ${CONTAINER_ENGINE}"

echo
echo "========================================"
echo "Trivy scan"
echo "========================================"

trivy image \
  --input "${IMAGE_ARCHIVE}" \
  --cache-backend memory \
  --scanners vuln \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  --skip-version-check

echo
echo "========================================"
echo "Grype scan"
echo "========================================"

grype "docker-archive:${IMAGE_ARCHIVE}" \
  --only-fixed \
  --fail-on high

echo
echo "========================================"
echo "All local checks passed"
echo "========================================"
