#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/cuda/bin:$PATH
for tool in gcc g++ make cmake ninja pkg-config nvcc btop nvtop curl git ssh tmux numactl jq; do
  command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 1; }
done
gpu_codes=$(nvcc --list-gpu-code)
for architecture in 70 75 86 89; do
  grep -Fx "sm_${architecture}" <<< "$gpu_codes" >/dev/null
done
nvcc --version
gcc -dumpfullversion
btop --version
nvtop --version
test -x /usr/local/bin/cuda-preflight
test ! -d /opt/conda
test ! -d /opt/sglang
if dpkg-query -W -f='${Package}\n' | grep -E '^(nvidia-driver-|cuda-drivers|python3-pip|python3-torch|python3-tensorflow)' >/dev/null; then
  echo 'Unexpected driver installer or ML package' >&2
  exit 1
fi
echo TOOLCHAIN_SM70_SM75_SM86_SM89_VERIFIED
