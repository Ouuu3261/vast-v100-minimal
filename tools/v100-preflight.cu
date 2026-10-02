#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>

static void check(cudaError_t status, const char *operation) {
    if (status != cudaSuccess) {
        std::fprintf(stderr, "%s: %s\n", operation, cudaGetErrorString(status));
        std::exit(1);
    }
}

__global__ void fill(int *values) {
    const unsigned index = threadIdx.x;
    values[index] = static_cast<int>(index * 3 + 7);
}

int main(int argc, char **argv) {
    const int expected = argc > 1 ? std::atoi(argv[1]) : 0;
    if (expected < 0) return 2;
    int count = 0, driver = 0, runtime = 0;
    check(cudaGetDeviceCount(&count), "cudaGetDeviceCount");
    check(cudaDriverGetVersion(&driver), "cudaDriverGetVersion");
    check(cudaRuntimeGetVersion(&runtime), "cudaRuntimeGetVersion");
    if (count == 0 || (expected && count != expected)) {
        std::fprintf(stderr, "GPU count %d, expected %d\n", count, expected);
        return 1;
    }
    std::printf("CUDA driver API=%d runtime=%d GPU count=%d\n", driver, runtime, count);
    for (int device = 0; device < count; ++device) {
        check(cudaSetDevice(device), "cudaSetDevice");
        cudaDeviceProp properties{};
        check(cudaGetDeviceProperties(&properties, device), "cudaGetDeviceProperties");
        if (properties.major != 7 || properties.minor != 0) {
            std::fprintf(stderr, "GPU %d is %s sm_%d%d; this image test targets V100 sm_70\n",
                         device, properties.name, properties.major, properties.minor);
            return 1;
        }
        int *buffer = nullptr, host[256]{};
        check(cudaMalloc(&buffer, sizeof(host)), "cudaMalloc 1 KiB");
        fill<<<1, 256>>>(buffer);
        check(cudaGetLastError(), "fill kernel launch");
        check(cudaDeviceSynchronize(), "cudaDeviceSynchronize");
        check(cudaMemcpy(host, buffer, sizeof(host), cudaMemcpyDeviceToHost), "cudaMemcpy");
        check(cudaFree(buffer), "cudaFree");
        for (int index = 0; index < 256; ++index) {
            if (host[index] != index * 3 + 7) {
                std::fprintf(stderr, "GPU %d roundtrip verification failed at %d\n", device, index);
                return 1;
            }
        }
        std::printf("PASS GPU %d: %s sm_70 %.2f GiB; 1 KiB CUDA kernel roundtrip\n",
                    device, properties.name, properties.totalGlobalMem / 1073741824.0);
    }
    return 0;
}
