#!/usr/bin/env bash
# Python-free build script
set -euo pipefail
export PATH="${HOME}/.local/bin:${PATH}"
export LIBRARY_PATH="${HOME}/.local/lib:${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="${HOME}/.local/lib:${LD_LIBRARY_PATH:-}"

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "==> Building Futhark kernels (multicore)"
(cd "$ROOT/futhark" && make multicore)

echo "==> Building Crystal host"
mkdir -p "$ROOT/crystal/bin"
(cd "$ROOT/crystal" && crystal build src/main.cr -o bin/fc-stack --release \
  --link-flags="-L${HOME}/.local/lib")
(cd "$ROOT/crystal" && crystal build ../examples/client.cr -o bin/client --release \
  --link-flags="-L${HOME}/.local/lib")

echo "==> Done. Binaries in crystal/bin/"
echo " Note: if the artifacts mount is noexec, copy binaries to /tmp before running."
