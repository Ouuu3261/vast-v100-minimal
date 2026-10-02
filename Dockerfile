# syntax=docker/dockerfile:1
FROM nvidia/cuda:12.9.1-base-ubuntu24.04@sha256:5d2e53778e2180e01676aa8bac1aada242e95230ec97e21ecfb33de4e27cd1df

LABEL org.opencontainers.image.source="https://github.com/Ouuu3261/vast-v100-minimal" \
      org.opencontainers.image.description="Minimal V100 CUDA 12.9 C/C++ toolchain and terminal monitoring tools; no ML framework."

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    PATH=/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    CUDA_HOME=/usr/local/cuda \
    CMAKE_CUDA_ARCHITECTURES=70 \
    EXPECTED_GPU_COUNT=0

# Compiler/runtime development components only, avoiding the full toolkit,
# cuDNN, cuBLAS, Nsight, Python environments, and kernel driver packages.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      cuda-nvcc-12-9=12.9.86-1 \
      cuda-cudart-dev-12-9=12.9.79-1 \
      cuda-cccl-12-9=12.9.27-1 \
      build-essential cmake ninja-build pkg-config \
      btop nvtop curl ca-certificates wget git \
      openssh-server openssh-client tmux \
      numactl jq procps iproute2 less vim-tiny \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
 && rm -f /etc/ssh/ssh_host_* \
 && mkdir -p /workspace /run/sshd

COPY tools/ /opt/v100-tools/
RUN nvcc -O2 -std=c++17 -gencode arch=compute_70,code=sm_70 \
      /opt/v100-tools/v100-preflight.cu -o /usr/local/bin/v100-preflight \
 && chmod 0755 /opt/v100-tools/*.sh /usr/local/bin/v100-preflight \
 && /opt/v100-tools/verify-toolchain.sh

WORKDIR /workspace
CMD ["sleep", "infinity"]
