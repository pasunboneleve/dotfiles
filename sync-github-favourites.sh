#!/usr/bin/env bash
set -euo pipefail

expected_dir="${HOME}/src/projects"
expected_real="$(cd "${expected_dir}" && pwd -P)"
current_real="$(pwd -P)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_list="${1:-"${script_dir}/github-favourites.txt"}"

warn() {
  printf 'warning: %s\n' "$*" >&2
}

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'error: required command not found: %s\n' "${command_name}" >&2
    exit 1
  fi
}

confirm_directory() {
  local reply

  if [[ "${current_real}" == "${expected_real}" ]]; then
    return 0
  fi

  printf 'Current directory is %s, not %s.\n' "${current_real}" "${expected_real}" >&2
  printf 'Proceed here anyway? [y/N] ' >&2
  read -r reply

  case "${reply}" in
    y | Y | yes | YES)
      ;;
    *)
      printf 'Aborted.\n' >&2
      exit 1
      ;;
  esac
}

checkout_main_and_pull() {
  local repo_dir="$1"
  local full_name="$2"

  if ! git -C "${repo_dir}" checkout main; then
    warn "${full_name}: could not check out main"
    return 0
  fi

  if ! git -C "${repo_dir}" pull --ff-only; then
    warn "${full_name}: could not pull main with fast-forward only"
    return 0
  fi
}

sync_repo() {
  local full_name="$1"
  local repo_name="$2"
  local clone_url="$3"

  printf '\n==> %s\n' "${full_name}"

  if [[ -e "${repo_name}" && ! -d "${repo_name}" ]]; then
    warn "${full_name}: ${repo_name} exists but is not a directory"
    return 0
  fi

  if [[ ! -d "${repo_name}" ]]; then
    if ! git clone -- "${clone_url}" "${repo_name}"; then
      warn "${full_name}: clone failed"
      return 0
    fi
  fi

  if ! git -C "${repo_name}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    warn "${full_name}: ${repo_name} exists but is not a git work tree"
    return 0
  fi

  checkout_main_and_pull "${repo_name}" "${full_name}"
}

main() {
  require_command git
  confirm_directory

  if [[ ! -f "${repo_list}" ]]; then
    printf 'error: repository list not found: %s\n' "${repo_list}" >&2
    exit 1
  fi

  if [[ ! -s "${repo_list}" ]]; then
    printf 'No repositories listed in %s.\n' "${repo_list}"
    return 0
  fi

  while IFS= read -r full_name || [[ -n "${full_name}" ]]; do
    if [[ -z "${full_name}" || "${full_name}" == \#* ]]; then
      continue
    fi

    if [[ ! "${full_name}" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
      warn "skipping malformed repository name: ${full_name}"
      continue
    fi

    sync_repo "${full_name}" "${full_name##*/}" "git@github.com:${full_name}.git"
  done < "${repo_list}"
}

main "$@"
