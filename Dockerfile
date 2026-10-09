# syntax=docker/dockerfile:1
FROM ghcr.io/ouuu3261/vast-v100-minimal:cuda12.9.1-v1@sha256:d11412a2ae40510003a5677251766896b47ed24327edb4f3717ca533accf49a0

LABEL org.opencontainers.image.source="https://github.com/Ouuu3261/vast-v100-minimal" \
      org.opencontainers.image.description="Minimal CUDA 12.9 C/C++ toolchain for V100 and RTX 20/30/40 GPUs; automatic single/multi-GPU checks; no ML framework."

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    PATH=/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    CUDA_HOME=/usr/local/cuda \
    CUDAARCHS=native \
    CMAKE_CUDA_ARCHITECTURES=native \
    EXPECTED_GPU_COUNT=0

# Reuse the verified minimal toolchain and its large registry layers. This
# version adds only architecture-neutral tools and native SM70/75/86/89 code.

COPY tools/ /opt/cuda-tools/
RUN nvcc -O2 -std=c++17 \
      -gencode arch=compute_70,code=sm_70 \
      -gencode arch=compute_75,code=sm_75 \
      -gencode arch=compute_86,code=sm_86 \
      -gencode arch=compute_89,code=sm_89 \
      /opt/cuda-tools/cuda-preflight.cu -o /usr/local/bin/cuda-preflight \
 && rm -rf /opt/v100-tools /usr/local/bin/v100-preflight \
 && chmod 0755 /opt/cuda-tools/*.sh /usr/local/bin/cuda-preflight \
 && /opt/cuda-tools/verify-toolchain.sh

WORKDIR /workspace
CMD ["sleep", "infinity"]
