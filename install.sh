#!/usr/bin/env bash
#
# clean-viz installer for Codex
#
# Quick install:
#   curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash
#
# Options:
#   --dest DIR        Install into DIR (default: $CODEX_HOME/skills or ~/.codex/skills)
#   --name NAME       Install the skill as NAME (default: clean-viz)
#   --ref REF         Git ref to download (default: main)
#   --force           Replace an existing install at the destination
#   --local-repo DIR  Install from a local checkout instead of GitHub
#   --quiet           Suppress non-error output
#   --help            Show this help
#
set -euo pipefail

OWNER="${OWNER:-maksymsherman}"
REPO="${REPO:-clean-viz-skill}"
REF="${REF:-main}"
SKILL_PATH="${SKILL_PATH:-skills/clean-viz}"
DEST_ROOT_DEFAULT="${CODEX_HOME:-$HOME/.codex}/skills"
DEST_ROOT="${DEST_ROOT:-$DEST_ROOT_DEFAULT}"
SKILL_NAME="${SKILL_NAME:-clean-viz}"
FORCE=0
QUIET=0
LOCAL_REPO=""
TMP_DIR=""

usage() {
  cat <<EOF
Install the clean-viz skill into Codex.

Usage:
  install.sh [options]

Options:
  --dest DIR        Install into DIR (default: ${DEST_ROOT_DEFAULT})
  --name NAME       Install the skill as NAME (default: clean-viz)
  --ref REF         Git ref to download (default: main)
  --force           Replace an existing install at the destination
  --local-repo DIR  Install from a local checkout instead of GitHub
  --quiet           Suppress non-error output
  --help            Show this help

Environment overrides:
  OWNER, REPO, REF, SKILL_PATH, DEST_ROOT, SKILL_NAME
EOF
}

log() {
  if [ "$QUIET" -eq 0 ]; then
    printf '%s\n' "$*"
  fi
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [ -n "${TMP_DIR}" ] && [ -d "${TMP_DIR}" ]; then
    rm -rf "${TMP_DIR}"
  fi
}

download_file() {
  local url="$1"
  local output="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${url}" -o "${output}"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO "${output}" "${url}"
    return
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "${url}" "${output}" <<'PY'
import sys
import urllib.request

url, output = sys.argv[1], sys.argv[2]
with urllib.request.urlopen(url) as response, open(output, "wb") as handle:
    handle.write(response.read())
PY
    return
  fi

  die "Need one of: curl, wget, or python3"
}

resolve_repo_root() {
  if [ -n "${LOCAL_REPO}" ]; then
    if [ ! -d "${LOCAL_REPO}" ]; then
      die "Local repo not found: ${LOCAL_REPO}"
    fi
    (
      cd "${LOCAL_REPO}" >/dev/null 2>&1
      pwd
    )
    return
  fi

  command -v tar >/dev/null 2>&1 || die "tar is required to extract the downloaded archive"

  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/clean-viz-install.XXXXXX")"
  trap cleanup EXIT

  local archive_url="https://codeload.github.com/${OWNER}/${REPO}/tar.gz/${REF}"
  local archive_path="${TMP_DIR}/repo.tar.gz"
  download_file "${archive_url}" "${archive_path}"
  tar -xzf "${archive_path}" -C "${TMP_DIR}"

  local extracted_root="${TMP_DIR}/${REPO}-${REF}"
  if [ ! -d "${extracted_root}" ]; then
    extracted_root="$(find "${TMP_DIR}" -mindepth 1 -maxdepth 1 -type d -name "${REPO}-*" | head -n 1)"
  fi
  if [ -z "${extracted_root}" ] || [ ! -d "${extracted_root}" ]; then
    die "Could not locate the extracted repository contents"
  fi

  printf '%s\n' "${extracted_root}"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dest)
      [ "$#" -ge 2 ] || die "Missing value for --dest"
      DEST_ROOT="$2"
      shift 2
      ;;
    --name)
      [ "$#" -ge 2 ] || die "Missing value for --name"
      SKILL_NAME="$2"
      shift 2
      ;;
    --ref)
      [ "$#" -ge 2 ] || die "Missing value for --ref"
      REF="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --local-repo)
      [ "$#" -ge 2 ] || die "Missing value for --local-repo"
      LOCAL_REPO="$2"
      shift 2
      ;;
    --quiet)
      QUIET=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

repo_root="$(resolve_repo_root)"
skill_src="${repo_root}/${SKILL_PATH}"
target_dir="${DEST_ROOT}/${SKILL_NAME}"

[ -d "${skill_src}" ] || die "Skill directory not found: ${skill_src}"
[ -f "${skill_src}/SKILL.md" ] || die "SKILL.md not found in ${skill_src}"

mkdir -p "${DEST_ROOT}"
if [ -e "${target_dir}" ]; then
  if [ "${FORCE}" -ne 1 ]; then
    die "Destination already exists: ${target_dir} (use --force to replace it)"
  fi
  rm -rf "${target_dir}"
fi

cp -R "${skill_src}" "${target_dir}"

log ""
log "Installed clean-viz to ${target_dir}"
log "Restart Codex if it is currently running so the new skill is reloaded."
log ""
log "Smoke test prompt:"
log "  Create a matplotlib line chart with direct labels, range frames, and an audit summary."
