#!/usr/bin/env bash
#
# clean-viz installer for Codex, Claude Code, and Gemini CLI
#
# Quick install:
#   curl -fsSL https://raw.githubusercontent.com/maksymsherman/clean-viz-skill/main/install.sh | bash
#
# Options:
#   --targets LIST    Comma-separated targets: codex,claude,gemini (default: all)
#   --dest DIR        Install only into DIR instead of the default skill roots
#   --name NAME       Install the skill as NAME (default: clean-viz)
#   --ref REF         Git ref to download (default: main)
#   --force           Replace an existing install for selected targets
#   --local-repo DIR  Install from a local checkout instead of GitHub
#   --quiet           Suppress non-error output
#   --help            Show this help
#
set -euo pipefail
umask 022
shopt -s lastpipe 2>/dev/null || true

OWNER="${OWNER:-maksymsherman}"
REPO="${REPO:-clean-viz-skill}"
REF="${REF:-main}"
SKILL_PATH="${SKILL_PATH:-skills/clean-viz}"
CODEX_DEST_DEFAULT="${CODEX_HOME:-$HOME/.codex}/skills"
CLAUDE_DEST_DEFAULT="${CLAUDE_HOME:-$HOME/.claude}/skills"
GEMINI_DEST_DEFAULT="${GEMINI_HOME:-$HOME/.gemini}/skills"
TARGETS_DEFAULT="codex,claude,gemini"
TARGETS="${TARGETS:-$TARGETS_DEFAULT}"
DEST_ROOT=""
SKILL_NAME="${SKILL_NAME:-clean-viz}"
FORCE=0
QUIET=0
LOCAL_REPO=""
TMP_DIR=""
declare -a TARGET_LABELS=()
declare -a TARGET_ROOTS=()
declare -a TARGET_RESULTS=()

usage() {
  cat <<EOF
Install the clean-viz skill into Codex, Claude Code, and Gemini CLI.

Usage:
  install.sh [options]

Options:
  --targets LIST    Comma-separated targets to install: codex,claude,gemini
                    (default: ${TARGETS_DEFAULT})
  --dest DIR        Install only into DIR instead of the default skill roots
  --name NAME       Install the skill as NAME (default: clean-viz)
  --ref REF         Git ref to download (default: main)
  --force           Replace an existing install for selected targets
  --local-repo DIR  Install from a local checkout instead of GitHub
  --quiet           Suppress non-error output
  --help            Show this help

Default skill roots:
  Codex:       ${CODEX_DEST_DEFAULT}
  Claude Code: ${CLAUDE_DEST_DEFAULT}
  Gemini CLI:  ${GEMINI_DEST_DEFAULT}

Environment overrides:
  OWNER, REPO, REF, SKILL_PATH, TARGETS, SKILL_NAME,
  CODEX_HOME, CLAUDE_HOME, GEMINI_HOME
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

warn() {
  if [ "$QUIET" -eq 0 ]; then
    printf 'Warning: %s\n' "$*" >&2
  fi
}

ok() {
  if [ "$QUIET" -eq 0 ]; then
    printf '%s\n' "$*"
  fi
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

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s\n' "$value"
}

add_target() {
  local label="$1"
  local root="$2"
  TARGET_LABELS+=("$label")
  TARGET_ROOTS+=("$root")
}

resolve_targets() {
  TARGET_LABELS=()
  TARGET_ROOTS=()

  if [ -n "$DEST_ROOT" ]; then
    add_target "custom" "$DEST_ROOT"
    return
  fi

  local token normalized
  IFS=',' read -r -a raw_targets <<< "$TARGETS"
  for token in "${raw_targets[@]}"; do
    normalized="$(trim "$token" | tr '[:upper:]' '[:lower:]')"
    case "$normalized" in
      codex)
        add_target "codex" "$CODEX_DEST_DEFAULT"
        ;;
      claude)
        add_target "claude" "$CLAUDE_DEST_DEFAULT"
        ;;
      gemini)
        add_target "gemini" "$GEMINI_DEST_DEFAULT"
        ;;
      "")
        ;;
      *)
        die "Unknown target: ${token}"
        ;;
    esac
  done

  [ "${#TARGET_LABELS[@]}" -gt 0 ] || die "No install targets selected"
}

install_into_target() {
  local label="$1"
  local root="$2"
  local src="$3"
  local target_dir="${root}/${SKILL_NAME}"

  mkdir -p "$root"

  if [ -e "$target_dir" ]; then
    if [ "$FORCE" -eq 1 ]; then
      rm -rf "$target_dir"
      cp -R "$src" "$target_dir"
      TARGET_RESULTS+=("${label}: updated (${target_dir})")
    else
      TARGET_RESULTS+=("${label}: already present, skipped (${target_dir})")
    fi
    return
  fi

  cp -R "$src" "$target_dir"
  TARGET_RESULTS+=("${label}: installed (${target_dir})")
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --targets)
      [ "$#" -ge 2 ] || die "Missing value for --targets"
      TARGETS="$2"
      shift 2
      ;;
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

[ -d "${skill_src}" ] || die "Skill directory not found: ${skill_src}"
[ -f "${skill_src}/SKILL.md" ] || die "SKILL.md not found in ${skill_src}"

resolve_targets
TARGET_RESULTS=()

for i in "${!TARGET_LABELS[@]}"; do
  install_into_target "${TARGET_LABELS[$i]}" "${TARGET_ROOTS[$i]}" "${skill_src}"
done

log ""
ok "Installed clean-viz for:"
for result in "${TARGET_RESULTS[@]}"; do
  log "  - ${result}"
done
log ""
log "Restart Codex, Claude Code, or Gemini CLI if they are currently running so the new skill is reloaded."
log ""
log "Smoke test prompt:"
log "  Create a matplotlib line chart with direct labels, range frames, and an audit summary."
