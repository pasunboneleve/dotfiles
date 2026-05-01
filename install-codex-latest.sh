#!/usr/bin/env bash

set -euo pipefail

readonly CODEX_REPO_API_URL="https://api.github.com/repos/openai/codex/releases/latest"
readonly CODEX_TARGET_TRIPLE="x86_64-unknown-linux-musl"
readonly CODEX_ARCHIVE_NAME="codex-${CODEX_TARGET_TRIPLE}.tar.gz"
readonly CODEX_BUNDLE_NAME="codex-${CODEX_TARGET_TRIPLE}.sigstore"
readonly CODEX_EXTRACTED_BINARY_NAME="codex-${CODEX_TARGET_TRIPLE}"
readonly CODEX_WORKFLOW_PATH=".github/workflows/rust-release.yml"
readonly CODEX_CERTIFICATE_OIDC_ISSUER="https://token.actions.githubusercontent.com"

readonly COSIGN_REPO_API_URL="https://api.github.com/repos/sigstore/cosign/releases/latest"
readonly COSIGN_BINARY_NAME="cosign-linux-amd64"
readonly COSIGN_SIGNATURE_JSON_NAME="cosign-linux-amd64-kms.sigstore.json"
readonly COSIGN_PUBLIC_KEY_NAME="release-cosign.pub"

readonly INSTALL_DIR="${HOME}/.local/bin"
readonly INSTALL_PATH="${INSTALL_DIR}/codex"

require_command() {
  local command_name=$1

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "${command_name}" >&2
    exit 1
  fi
}

download_release_asset_url() {
  local release_json_path=$1
  local asset_name=$2

  jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .browser_download_url' "${release_json_path}"
}

cleanup() {
  if [[ -n "${TMPDIR_PATH:-}" && -d "${TMPDIR_PATH}" ]]; then
    rm -rf "${TMPDIR_PATH}"
  fi
}

trap cleanup EXIT

require_command curl
require_command jq
require_command tar
require_command mktemp
require_command install
require_command mv
require_command chmod
require_command openssl
require_command base64

TMPDIR_PATH=$(mktemp -d)
readonly TMPDIR_PATH

readonly CODEX_RELEASE_JSON_PATH="${TMPDIR_PATH}/codex-release.json"
readonly CODEX_ARCHIVE_PATH="${TMPDIR_PATH}/${CODEX_ARCHIVE_NAME}"
readonly CODEX_BUNDLE_PATH="${TMPDIR_PATH}/${CODEX_BUNDLE_NAME}"
readonly CODEX_EXTRACT_DIR="${TMPDIR_PATH}/codex-extract"
readonly CODEX_CANDIDATE_PATH="${CODEX_EXTRACT_DIR}/${CODEX_EXTRACTED_BINARY_NAME}"

readonly COSIGN_RELEASE_JSON_PATH="${TMPDIR_PATH}/cosign-release.json"
readonly COSIGN_BINARY_PATH="${TMPDIR_PATH}/${COSIGN_BINARY_NAME}"
readonly COSIGN_SIGNATURE_JSON_PATH="${TMPDIR_PATH}/${COSIGN_SIGNATURE_JSON_NAME}"
readonly COSIGN_PUBLIC_KEY_PATH="${TMPDIR_PATH}/${COSIGN_PUBLIC_KEY_NAME}"
readonly COSIGN_SIGNATURE_PATH="${TMPDIR_PATH}/${COSIGN_BINARY_NAME}.sig"

printf 'Fetching latest cosign release metadata from %s\n' "${COSIGN_REPO_API_URL}"
curl -fsSL "${COSIGN_REPO_API_URL}" -o "${COSIGN_RELEASE_JSON_PATH}"

COSIGN_TAG_NAME=$(jq -r '.tag_name' "${COSIGN_RELEASE_JSON_PATH}")
COSIGN_BINARY_URL=$(download_release_asset_url "${COSIGN_RELEASE_JSON_PATH}" "${COSIGN_BINARY_NAME}")
COSIGN_SIGNATURE_JSON_URL=$(download_release_asset_url "${COSIGN_RELEASE_JSON_PATH}" "${COSIGN_SIGNATURE_JSON_NAME}")
COSIGN_PUBLIC_KEY_URL=$(download_release_asset_url "${COSIGN_RELEASE_JSON_PATH}" "${COSIGN_PUBLIC_KEY_NAME}")

if [[ -z "${COSIGN_TAG_NAME}" || "${COSIGN_TAG_NAME}" == "null" ]]; then
  printf 'Could not determine the latest cosign release tag.\n' >&2
  exit 1
fi

if [[ -z "${COSIGN_BINARY_URL}" || "${COSIGN_BINARY_URL}" == "null" ]]; then
  printf 'Could not find release asset %s for cosign tag %s.\n' "${COSIGN_BINARY_NAME}" "${COSIGN_TAG_NAME}" >&2
  exit 1
fi

if [[ -z "${COSIGN_SIGNATURE_JSON_URL}" || "${COSIGN_SIGNATURE_JSON_URL}" == "null" ]]; then
  printf 'Could not find release asset %s for cosign tag %s.\n' "${COSIGN_SIGNATURE_JSON_NAME}" "${COSIGN_TAG_NAME}" >&2
  exit 1
fi

if [[ -z "${COSIGN_PUBLIC_KEY_URL}" || "${COSIGN_PUBLIC_KEY_URL}" == "null" ]]; then
  printf 'Could not find release asset %s for cosign tag %s.\n' "${COSIGN_PUBLIC_KEY_NAME}" "${COSIGN_TAG_NAME}" >&2
  exit 1
fi

printf 'Downloading %s\n' "${COSIGN_BINARY_NAME}"
curl -fsSL "${COSIGN_BINARY_URL}" -o "${COSIGN_BINARY_PATH}"

printf 'Downloading %s\n' "${COSIGN_SIGNATURE_JSON_NAME}"
curl -fsSL "${COSIGN_SIGNATURE_JSON_URL}" -o "${COSIGN_SIGNATURE_JSON_PATH}"

printf 'Downloading %s\n' "${COSIGN_PUBLIC_KEY_NAME}"
curl -fsSL "${COSIGN_PUBLIC_KEY_URL}" -o "${COSIGN_PUBLIC_KEY_PATH}"

jq -r '.messageSignature.signature' "${COSIGN_SIGNATURE_JSON_PATH}" | base64 -d > "${COSIGN_SIGNATURE_PATH}"

printf 'Verifying downloaded cosign binary with the published cosign release key\n'
openssl dgst -sha256 \
  -verify "${COSIGN_PUBLIC_KEY_PATH}" \
  -signature "${COSIGN_SIGNATURE_PATH}" \
  "${COSIGN_BINARY_PATH}" >/dev/null

chmod 0755 "${COSIGN_BINARY_PATH}"

printf 'Fetching latest Codex release metadata from %s\n' "${CODEX_REPO_API_URL}"
curl -fsSL "${CODEX_REPO_API_URL}" -o "${CODEX_RELEASE_JSON_PATH}"

CODEX_TAG_NAME=$(jq -r '.tag_name' "${CODEX_RELEASE_JSON_PATH}")
CODEX_ARCHIVE_URL=$(download_release_asset_url "${CODEX_RELEASE_JSON_PATH}" "${CODEX_ARCHIVE_NAME}")
CODEX_BUNDLE_URL=$(download_release_asset_url "${CODEX_RELEASE_JSON_PATH}" "${CODEX_BUNDLE_NAME}")

if [[ -z "${CODEX_TAG_NAME}" || "${CODEX_TAG_NAME}" == "null" ]]; then
  printf 'Could not determine the latest Codex release tag.\n' >&2
  exit 1
fi

if [[ -z "${CODEX_ARCHIVE_URL}" || "${CODEX_ARCHIVE_URL}" == "null" ]]; then
  printf 'Could not find release asset %s for Codex tag %s.\n' "${CODEX_ARCHIVE_NAME}" "${CODEX_TAG_NAME}" >&2
  exit 1
fi

if [[ -z "${CODEX_BUNDLE_URL}" || "${CODEX_BUNDLE_URL}" == "null" ]]; then
  printf 'Could not find release asset %s for Codex tag %s.\n' "${CODEX_BUNDLE_NAME}" "${CODEX_TAG_NAME}" >&2
  exit 1
fi

printf 'Downloading %s\n' "${CODEX_ARCHIVE_NAME}"
curl -fsSL "${CODEX_ARCHIVE_URL}" -o "${CODEX_ARCHIVE_PATH}"

printf 'Downloading %s\n' "${CODEX_BUNDLE_NAME}"
curl -fsSL "${CODEX_BUNDLE_URL}" -o "${CODEX_BUNDLE_PATH}"

mkdir -p "${CODEX_EXTRACT_DIR}"
printf 'Extracting codex from %s\n' "${CODEX_ARCHIVE_NAME}"
tar -xzf "${CODEX_ARCHIVE_PATH}" -C "${CODEX_EXTRACT_DIR}"

if [[ ! -f "${CODEX_CANDIDATE_PATH}" ]]; then
  printf 'Expected extracted binary at %s, but it was not found.\n' "${CODEX_CANDIDATE_PATH}" >&2
  exit 1
fi

CODEX_CERTIFICATE_IDENTITY="https://github.com/openai/codex/${CODEX_WORKFLOW_PATH}@refs/tags/${CODEX_TAG_NAME}"
readonly CODEX_CERTIFICATE_IDENTITY

printf 'Verifying extracted Codex binary with Sigstore\n'
"${COSIGN_BINARY_PATH}" verify-blob \
  --bundle "${CODEX_BUNDLE_PATH}" \
  --certificate-identity "${CODEX_CERTIFICATE_IDENTITY}" \
  --certificate-oidc-issuer "${CODEX_CERTIFICATE_OIDC_ISSUER}" \
  "${CODEX_CANDIDATE_PATH}" >/dev/null

install -d "${INSTALL_DIR}"
chmod 0755 "${CODEX_CANDIDATE_PATH}"
mv -f "${CODEX_CANDIDATE_PATH}" "${INSTALL_PATH}"

printf 'Installed verified Codex binary to %s\n' "${INSTALL_PATH}"
