#!/usr/bin/env bash
# Wrapper that exec's xtensa-esp32-elf-gdb with the ESP-IDF environment active.
# VSCode's cppdbg launch config uses this as miDebuggerPath, so it stays
# stable across ESP-IDF/toolchain upgrades.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
IDF_DIR="${REPO_DIR}/esp-idf"

if [[ ! -f "${IDF_DIR}/export.sh" ]]; then
  echo "ESP-IDF not found at ${IDF_DIR}. Run ./setup.sh first." >&2
  exit 1
fi

export PATH="/opt/homebrew/opt/python@3.12/bin:${PATH:-}"
# shellcheck disable=SC1091
source "${IDF_DIR}/export.sh" > /dev/null

exec xtensa-esp32-elf-gdb "$@"
