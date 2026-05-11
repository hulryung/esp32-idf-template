#!/usr/bin/env bash
# Run any command inside the ESP-IDF environment.
# Used by VSCode tasks so they don't depend on the user's shell rc.
#
# Usage: ./scripts/idf-run.sh <cwd> <cmd> [args...]
#   <cwd> is the working directory (typically a project under projects/)

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <cwd> <command> [args...]" >&2
  exit 2
fi

CWD="$1"; shift

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

cd "${CWD}"
exec "$@"
