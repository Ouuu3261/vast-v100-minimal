#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/cuda/bin:$PATH
for tool in gcc g++ make cmake ninja pkg-config nvcc btop nvtop curl git ssh tmux numactl jq; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 1; }
done
nvcc --list-gpu-code | grep -Fx sm_70 >/dev/null
nvcc --version
gcc --version | head -n 1
btop --version
nvtop --version
test -x /usr/local/bin/v100-preflight
test ! -d /opt/conda
test ! -d /opt/sglang
if dpkg-query -W -f='${Package}\n' | grep -E '^(nvidia-driver-|cuda-drivers|python3-pip|python3-torch|python3-tensorflow)' >/dev/null; then
  echo 'Unexpected driver installer or ML package' >&2
  exit 1
fi
echo TOOLCHAIN_SM70_VERIFIED
