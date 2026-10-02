#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mkdir -p /workspace
exec > >(tee -a /workspace/v100-preflight.log) 2>&1
echo "V100 minimal environment preflight: $(date -u +%FT%TZ)"
echo 'NVIDIA kernel driver and NVML are provided by the Vast host.'
nvidia-smi --query-gpu=index,name,driver_version,memory.total --format=csv
/opt/v100-tools/verify-toolchain.sh
v100-preflight "${EXPECTED_GPU_COUNT:-0}"
echo 'READY: CUDA compiler, all assigned V100 GPUs, and monitoring tools verified.'
