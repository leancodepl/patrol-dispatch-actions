#!/usr/bin/env bash
# A job stages dart-defines once: a second value would silently shadow the
# first.
set -euo pipefail

if [[ -n "${DART_DEFINES:-}" && -n "${DART_DEFINES_FILE:-}" ]]; then
  echo "::error title=dart-defines configured twice::Set dart-defines or dart-defines-file, not both."
  exit 1
fi

if [[ -n "${PD_DART_DEFINES_FILE:-}" ]]; then
  if [[ -n "${DART_DEFINES:-}${DART_DEFINES_FILE:-}" ]]; then
    echo "::error title=dart-defines configured twice::PD_DART_DEFINES_FILE is already set; pass dart-defines once per job."
    exit 1
  fi
  exit 0
fi

# The CLI reads and checks the file.
if [[ -n "${DART_DEFINES_FILE:-}" ]]; then
  echo "PD_DART_DEFINES_FILE=$GITHUB_WORKSPACE/$DART_DEFINES_FILE" >> "$GITHUB_ENV"
  exit 0
fi

[[ -z "${DART_DEFINES:-}" ]] && exit 0

if ! jq -e 'type == "object" and all(.[]; type == "string")' \
  <<< "$DART_DEFINES" >/dev/null 2>&1; then
  echo "::error title=Invalid dart-defines::dart-defines must be a JSON object of string values."
  exit 1
fi

# Holds credentials, so it stays out of the workspace and owner-only.
defines_file="${RUNNER_TEMP:-/tmp}/patrol-dart-defines.json"
install -m 600 /dev/null "$defines_file"
jq -S '.' <<< "$DART_DEFINES" > "$defines_file"
echo "PD_DART_DEFINES_FILE=$defines_file" >> "$GITHUB_ENV"
