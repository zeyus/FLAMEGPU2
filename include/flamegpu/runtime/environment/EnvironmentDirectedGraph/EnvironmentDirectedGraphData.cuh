#ifndef INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDATA_CUH_
#define INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDATA_CUH_

#include <string>

#include "flamegpu/runtime/environment/EnvironmentDirectedGraph.cuh"
#include "flamegpu/model/Variable.h"
#include "flamegpu/model/ModelData.h"

namespace flamegpu {
/**
 * This is the internal data store for EnvironmentDirectedGraph::Description
 * Users should only access that data stored within via an instance of EnvironmentDirectedGraph::Description
 */
struct EnvironmentDirectedGraph::Data : std::enable_shared_from_this<EnvironmentDirectedGraph::Data> {

    /**
     * Holds all of the graphs's vertex property definitions
     */
    VariableMap vertexProperties;
    /**
     * Holds all of the graphs's edge property definitions
     */
    VariableMap edgeProperties;
    /**
     * Description class which provides convenient accessors
     * This may be null if the instance has been cloned
     */
    std::shared_ptr<EnvironmentDirectedGraph::Description> description;
    /**
     * Name of the graph, used to refer to the graph in many functions
     */
    std::string name;
    /**
     * Equality operator, checks whether AgentData hierarchies are functionally the same
     * @param rhs Right hand side
     * @returns True when agents are the same
     * @note Instead compare pointers if you wish to check that they are the same instance
     */
    bool operator==(const Data& rhs) const;
    /**
     * Equality operator, checks whether AgentData hierarchies are functionally different
     * @param rhs Right hand side
     * @returns True when agents are not the same
     * @note Instead compare pointers if you wish to check that they are not the same instance
     */
    bool operator!=(const Data& rhs) const;
    /**
     * Default copy constructor, not implemented
     */
    Data(const Data& other) = delete;
    /**
     * Returns a constant copy of this agent's hierarchy
     * Does not copy description, sets it to nullptr instead
     * @return A shared ptr to a copy
     */
    std::shared_ptr<const Data> clone() const;

 protected:
    /**
     * Copy constructor
     * This is unsafe, should only be used internally, use clone() instead
     * This does not setup functions map
     * @param model New parent model (we do not copy the other AgentData's parent model)
     * @param other Other AgentData to copy data from
     */
    Data(std::shared_ptr<const ModelData> model, const Data& other);
    /**
     * Normal constructor, only to be called by ModelDescription
     * @param model Parent model
     * @param agent_name Name of the agent
     */
    Data(std::shared_ptr<const ModelData> model, const std::string& agent_name);
};
}  // namespace flamegpu

#endif  // INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDATA_CUH_
