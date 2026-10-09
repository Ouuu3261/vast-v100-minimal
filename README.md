# CUDA minimal development image

Ubuntu 24.04 and CUDA 12.9.1 for Linux amd64 V100 and GeForce RTX 20/30/40
GPUs. Includes NVCC, CUDA runtime headers, GCC/G++, Make, CMake, Ninja,
pkg-config, btop, nvtop, curl, Git, SSH, tmux, numactl, jq, and terminal tools.

| GPUs | Native CUDA architecture |
| --- | --- |
| Tesla V100 | SM70 |
| Desktop RTX 2060/2070/2080 and variants | SM75 |
| RTX 30 series | SM86 |
| RTX 40 series | SM89 |

The image contains no PyTorch, TensorFlow, TGI, cuDNN, cuBLAS, Jupyter, Conda,
or kernel driver installer. NVIDIA drivers, libcuda, NVML, and nvidia-smi come
from the NVIDIA container runtime on the Vast host. Multi-GPU use by a real
application depends on that application's own device selection and scheduling.

CUDA 12.9 supports all four architectures. CUDA 13 removed offline compiler
and library support for Volta, so this image retains CUDA 12.9 for V100.
[NVIDIA compiler targets](https://docs.nvidia.com/cuda/archive/12.9.1/cuda-compiler-driver-nvcc/index.html).

## Vast template

Use SSH launch mode with:

```bash
bash /opt/cuda-tools/onstart.sh
```

Set `EXPECTED_GPU_COUNT=0` to check every GPU allocated to the instance,
regardless of whether it has one, two, four, or eight cards. A positive value
requires exactly that number. The template allows 1/2/4/8 GPUs, at least 24GB
system RAM, 30GB disk, and host CUDA capability 12.4 or newer. GPU VRAM is not
restricted; size it for the intended workload. Verified-host and bandwidth-price
filters are retained.

The startup check discovers the actual architecture of each assigned GPU and
runs a 1KiB memory/kernel roundtrip on each device. The executable includes
native SM70, SM75, SM86, and SM89 code, without relying on PTX JIT on older
drivers. Logs are written to `/workspace/cuda-preflight.log`; success ends with:

```text
READY: CUDA compiler, all assigned GPUs, and monitoring tools verified.
```

Host CUDA 12.4+ is a search threshold, not a guarantee for every application.
CUDA 12 minor-version compatibility supports the native-code startup test on
compatible drivers. Newer driver features or PTX JIT can require a newer driver.
[NVIDIA compatibility guidance](https://docs.nvidia.com/deploy/cuda-compatibility/minor-version-compatibility.html).

## Compile for the assigned GPUs

`CUDAARCHS=native` initializes CMake's CUDA architecture selection using the
visible GPUs. `CMAKE_CUDA_ARCHITECTURES=native` is also available as a shell
variable for build scripts that explicitly pass it to CMake. For NVCC:

```bash
nvcc -O2 -arch=native example.cu -o example
cmake -S . -B build -DCMAKE_CUDA_ARCHITECTURES=native
btop
nvtop
```

For binaries intended for another machine, explicitly select that machine's
architectures instead of `native`.

## Image and validation

```text
ghcr.io/ouuu3261/vast-v100-minimal:cuda12.9.1-generic-v2
```

The repository/registry path is retained for compatibility. This generic version
uses the original, independently verified `cuda12.9.1-v1` image by digest as its
base, reusing its compiler/runtime packages and large download layers. It adds
only the generic startup tools and multi-architecture preflight executable.
The old V100 image tag is not overwritten.

GitHub Actions builds Linux amd64, verifies tool/package inventory, compiles
native code for all four architectures, and publishes the image. CPU-only CI
does not prove GPU execution; the startup test verifies the actual rented GPUs.
Keep architecture compilation, single-GPU runtime evidence, and multi-GPU
runtime evidence separate when assessing support.
