# V100 minimal CUDA development image

Ubuntu 24.04 and CUDA 12.9.1 for Linux amd64 Tesla V100 (Volta, SM70).
Includes NVCC, CUDA runtime headers, GCC/G++, Make, CMake, Ninja, pkg-config,
btop, nvtop, curl, Git, SSH, tmux, numactl, jq, and standard terminal tools.

The image installs only the CUDA compiler and runtime development components.
It contains no PyTorch, TensorFlow, TGI, cuDNN, cuBLAS, Jupyter, Conda, or kernel
driver installer. NVIDIA kernel drivers, libcuda, NVML, and nvidia-smi come from
the NVIDIA container runtime on the Vast host.

CUDA 12.9 supports offline SM70 compilation. CUDA 13 removed offline compiler
and library support for Volta. [NVIDIA CUDA 13 release notes](https://docs.nvidia.com/cuda/archive/13.0.0/cuda-toolkit-release-notes/index.html).

## Vast template

Use SSH launch mode. Its startup command is:

```bash
bash /opt/v100-tools/onstart.sh
```

Set `EXPECTED_GPU_COUNT=8` for an eight-card rental. Recommended total container
disk is 30 GB, and the offer must provide at least 48 GB RAM. The template uses
CUDA-capable V100 hosts and filters out expensive bandwidth offers.

The startup check enumerates assigned GPUs and runs a 1 KiB CUDA memory/kernel
roundtrip on each V100. It reports success only after checking all assigned
devices. It does not launch a model or any training workload.

```bash
nvcc -O2 -gencode arch=compute_70,code=sm_70 example.cu -o example
btop
nvtop
```

The default CMake CUDA architecture is 70. No Python environment is required.
GPU execution is checked on the rented host; the public CI runner verifies
image construction, installed tools, and native SM70 compilation without a GPU.

## Image

```text
ghcr.io/ouuu3261/vast-v100-minimal:cuda12.9.1-v1
```

Build inputs pin the Linux amd64 CUDA base image digest and the CUDA 12.9.1
compiler and runtime header package versions. Ubuntu maintenance packages
follow the current Ubuntu 24.04 repositories. A successful CI build records
the final image size and package inventory. Pin the published image digest
when strict reproduction is required.
