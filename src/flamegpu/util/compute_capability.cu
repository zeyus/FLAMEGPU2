#include "flamegpu/util/compute_capability.cuh"
#include "flamegpu/gpu/CUDAErrorChecking.h"

int util::compute_capability::getComputeCapability(int deviceIndex) {
    int major = 0;
    int minor = 0;

    // Throw an exception if the deviceIndex is negative.
    if (deviceIndex < 0) {
        THROW InvalidCUDAdevice();
    }

    // Ensure deviceIndex is valid.
    int deviceCount = 0;
    gpuErrchk(cudaGetDeviceCount(&deviceCount));
    if (deviceIndex >= deviceCount) {
        // Throw an excpetion if the device index is bad.
        THROW InvalidCUDAdevice();
    }
    // Load device attributes
    gpuErrchk(cudaDeviceGetAttribute(&minor, cudaDevAttrComputeCapabilityMinor, deviceIndex));
    gpuErrchk(cudaDeviceGetAttribute(&major, cudaDevAttrComputeCapabilityMajor, deviceIndex));
    // Compute the arch integer value.
    int arch = (10 * major) + minor;
    return arch;
}

int util::compute_capability::minimumCompiledComputeCapability() {
    #if defined(MIN_ARCH)
        return MIN_ARCH;
    #else
        // Return 0 as a default minimum?
        return 0;
    #endif
}

bool util::compute_capability::checkComputeCapability(int deviceIndex) {
    // If the compile time minimum architecture is defined, fetch the device's compute capability and check that the executable (probably) supports this device.
    #if defined(MIN_ARCH)
        if (getComputeCapability(deviceIndex) < MIN_ARCH) {
            return false;
        } else {
            return true;
        }
    #else
        // If not defined, we cannot make a decision so assume it will work?
        return true;
    #endif
}