// Modified temporary example to demonstrate proof of concept of RTC cuJit patching

#include <cuda_runtime.h>
#include <random>
#include <memory>

#include "flamegpu/util/detail/compute_capability.cuh"

#ifdef _MSC_VER
#pragma warning(push, 2)
#include "jitify/jitify.hpp"
#pragma warning(pop)
#else
#include "jitify/jitify.hpp"
#endif

#if defined(_DEBUG) || defined(D_DEBUG)
#define CUDA_CALL(ans) { gpuAssert((ans), __FILE__, __LINE__); }
#define CUDA_CHECK(location) { gpuAssert(cudaDeviceSynchronize(), __FILE__, __LINE__); }
#else
#define CUDA_CALL(ans) { gpuAssert((ans), __FILE__, __LINE__); }
#define CUDA_CHECK(location) { gpuAssert(cudaPeekAtLastError(), __FILE__, __LINE__); }
#endif
inline void gpuAssert(cudaError_t code, const char* file, int line) {
    if (code != cudaSuccess) {
        if (line >= 0) {
            fprintf(stderr, "CUDA Error: %s(%d): %s", file, line, cudaGetErrorString(code));
        }
        else {
            fprintf(stderr, "CUDA Error: %s(%d): %s", file, line, cudaGetErrorString(code));
        }
        exit(EXIT_FAILURE);
    }
}

const char* test_kernel_src = R"###(
__device__ float input[1];
__global__ void test_patching(float *output, const size_t len) {
    for(int i = 0; i < len; ++i)
        output[i] = input[i];
}
)###";

int main(int argc, const char ** argv) {

    CUDA_CALL(cudaFree(nullptr));

    // Allocate buffers
    const size_t INPUT_LEN = 100;
    float* d_input = nullptr, *d_output = nullptr;
    float *h_input = nullptr, *h_output = nullptr;
    CUDA_CALL(cudaMalloc(&d_input, INPUT_LEN * sizeof(float)));
    CUDA_CALL(cudaMalloc(&d_output, INPUT_LEN * sizeof(float)));
    h_input = (float*)malloc(INPUT_LEN * sizeof(float));
    h_output = (float*)malloc(INPUT_LEN * sizeof(float));

    // Fill buffer with random data
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(-1.0, 1.0);
    for (int i = 0; i < INPUT_LEN; ++i)
        h_input[i] = dis(gen);
    CUDA_CALL(cudaMemcpy(d_input, h_input, INPUT_LEN * sizeof(float), cudaMemcpyHostToDevice));

    // Compile the kernel
   
    // vector of compiler options for jitify
    std::vector<std::string> options;
    std::vector<std::string> headers;

    // Set the compilation architecture target if it was successfully detected.
    int currentDeviceIdx = 0;
    cudaError_t status = cudaGetDevice(&currentDeviceIdx);
    if (status == cudaSuccess) {
        int arch = flamegpu::util::detail::compute_capability::getComputeCapability(currentDeviceIdx);
        options.push_back(std::string("--gpu-architecture=compute_" + std::to_string(arch)));
    }

    // jitify to create program (with compilation settings)
    std::unique_ptr<jitify::experimental::KernelInstantiation> kernel_instance;
    try {
        auto program = jitify::experimental::Program(test_kernel_src, headers, options);
        auto kernel = program.kernel("test_patching");
        kernel_instance = std::make_unique<jitify::experimental::KernelInstantiation>(kernel, std::vector<std::string>{});
    } catch (std::runtime_error const&) {
        fprintf(stderr, "Compilation failed, see stdout.\n");
        return EXIT_FAILURE;
    }

    // Serialise
    std::string serialized_kernel = kernel_instance->serialize();

    {
        // Deserialise with cujit options
        const unsigned int nopts = 3;
        CUjit_option opts[3] = { CU_JIT_GLOBAL_SYMBOL_COUNT, CU_JIT_GLOBAL_SYMBOL_NAMES, CU_JIT_GLOBAL_SYMBOL_ADDRESSES };
        unsigned int SYMBOL_COUNT = 1;
        const char *SYMBOL_NAMES[1] = { "input" };
        void *SYMBOL_ADDRESSES[1] = { d_input };
        void *optvals[3] = { &SYMBOL_COUNT, SYMBOL_NAMES, SYMBOL_ADDRESSES };
        jitify::experimental::KernelInstantiation patched_kernel_instance =
        //jitify::experimental::KernelInstantiation::deserialize(serialized_kernel);
        jitify::experimental::KernelInstantiation::deserialize(serialized_kernel, nopts, opts, optvals);

        // Execute kernel
        CUresult a = patched_kernel_instance.configure(1, 1).launch({
            reinterpret_cast<void*>(&h_output),
            const_cast<void*>(reinterpret_cast<const void*>(&INPUT_LEN))
        });
        if (a != CUresult::CUDA_SUCCESS) {
            const char* err_str = nullptr;
            cuGetErrorString(a, &err_str);
            fprintf(stderr, "Executing instance 1 failed: %s\n", err_str);
            return EXIT_FAILURE;
        }
        CUDA_CHECK("Launch 1");
    }

    // Validate result
    CUDA_CALL(cudaMemcpy(h_output, d_output, INPUT_LEN * sizeof(float), cudaMemcpyDeviceToHost));
    unsigned int error_count = 0;
    for (int i = 0; i < INPUT_LEN; ++i)
        error_count += h_output[i] == h_input[i] ? 0 : 1;

    printf("Test 1 had %u errors!\n", error_count);

    // Deserialise with different cujit options

    // Execute kernel

    // Validate result

    return 0;
}

