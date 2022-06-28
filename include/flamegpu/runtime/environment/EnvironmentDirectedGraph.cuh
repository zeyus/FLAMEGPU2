#ifndef INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_CUH_
#define INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_CUH_

#include "flamegpu/runtime/utility/EnvironmentManager.cuh"

namespace flamegpu {
/**
 * Environment Directed Graph functionality
 *
 * A graph can be defined/filled via the HostAPI and then accessed via AgentFunctions
 * @todo Message? can be used to attach messages to the graph's structure
 */
class EnvironmentDirectedGraph {
 public:
    /**
     * Common size type
     */
    typedef EnvironmentManager::size_type size_type;

    // Host
    struct Data;        // Forward declare inner classes
    class Description;  // Forward declare inner classes
    class Host;

    // Device
    class Device;
};
}  // namespace flamegpu

#endif  // INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_CUH_
