#!/usr/bin/env bash
# Reproducible ESP-IDF v5.3 setup for macOS (Apple Silicon).
# Installs brew deps, clones ESP-IDF into ./esp-idf, installs toolchain + QEMU,
# and adds a `get_idf` alias to your shell rc.
#
# Usage: ./setup.sh

set -euo pipefail

IDF_VERSION="${IDF_VERSION:-release/v5.3}"
IDF_TARGETS="${IDF_TARGETS:-esp32}"   # space- or comma-separated; e.g. "esp32 esp32s3 esp32c3"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IDF_DIR="${REPO_DIR}/esp-idf"

echo "==> Repo dir:  ${REPO_DIR}"
echo "==> IDF dir:   ${IDF_DIR}"
echo "==> IDF ver:   ${IDF_VERSION}"
echo "==> Targets:   ${IDF_TARGETS}"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script targets macOS. For Linux/Windows see https://docs.espressif.com/projects/esp-idf/" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install from https://brew.sh and re-run." >&2
  exit 1
fi

echo "==> Installing Homebrew dependencies..."
brew install cmake ninja dfu-util ccache python@3.12 libslirp

export PATH="/opt/homebrew/opt/python@3.12/bin:$PATH"

if [[ ! -d "${IDF_DIR}" ]]; then
  echo "==> Cloning ESP-IDF (${IDF_VERSION})..."
  git clone -b "${IDF_VERSION}" --recursive --depth 1 --shallow-submodules \
    https://github.com/espressif/esp-idf.git "${IDF_DIR}"
else
  echo "==> ESP-IDF already present at ${IDF_DIR}, skipping clone"
fi

echo "==> Installing ESP-IDF toolchain for: ${IDF_TARGETS}"
(cd "${IDF_DIR}" && ./install.sh "${IDF_TARGETS// /,}")

echo "==> Installing QEMU (xtensa + riscv32) for emulation..."
(cd "${IDF_DIR}" && python3 tools/idf_tools.py install qemu-xtensa qemu-riscv32)

# Add shell alias
RC_FILE=""
case "${SHELL:-}" in
  */zsh)  RC_FILE="${HOME}/.zshrc"  ;;
  */bash) RC_FILE="${HOME}/.bashrc" ;;
esac

if [[ -n "${RC_FILE}" ]]; then
  if ! grep -q "alias get_idf=" "${RC_FILE}" 2>/dev/null; then
    echo "==> Adding 'get_idf' alias to ${RC_FILE}"
    {
      echo ""
      echo "# ESP-IDF activation (added by esp32-idf-template setup.sh)"
      echo "alias get_idf='export PATH=\"/opt/homebrew/opt/python@3.12/bin:\$PATH\" && . ${IDF_DIR}/export.sh'"
    } >> "${RC_FILE}"
  else
    echo "==> 'get_idf' alias already present in ${RC_FILE}"
  fi
fi

cat <<EOF

==> Setup complete.

Open a new terminal and run:
    get_idf                                # activate ESP-IDF environment
    cd projects/hello_world
    idf.py set-target esp32
    idf.py build
    idf.py qemu                            # emulate (Ctrl+A then X to quit)
    idf.py -p /dev/cu.usbserial-XXXX flash monitor    # real device

EOF
