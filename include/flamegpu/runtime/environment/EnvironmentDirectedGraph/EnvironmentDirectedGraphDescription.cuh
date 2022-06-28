#ifndef INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDESCRIPTION_CUH_
#define INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDESCRIPTION_CUH_

#include "flamegpu/runtime/environment/EnvironmentDirectedGraph.cuh"
#include "flamegpu/model/EnvironmentDescription.h"

namespace flamegpu {
/**
 * @todo
 */
class EnvironmentDirectedGraph::Description {
    /**
      * Data store class for this description, constructs instances of this class
      */
    friend struct AgentData;
    /**
     * Only way to construct an AgentDescription
     */
    friend EnvironmentDirectedGraph::Description& EnvironmentDescription::newDirectedGraph(const std::string&);

    /**
     * Constructor, this should only be called by EnvironmentDirectedGraph::Data
     * @param _model Model at root of model hierarchy
     * @param data Data store of this agent's data
     */
    Description(std::shared_ptr<const ModelData> _model, EnvironmentDirectedGraph::Data* const data);
    /**
     * Default copy constructor, not implemented
     */
    Description(const Description& other_agent) = delete;
    /**
     * Default move constructor, not implemented
     */
    Description(Description&& other_agent) noexcept = delete;
    /**
     * Default copy assignment, not implemented
     */
    Description& operator=(const Description& other_agent) = delete;
    /**
     * Default move assignment, not implemented
     */
    Description& operator=(Description&& other_agent) noexcept = delete;

public:
    /**
     * Equality operator, checks whether AgentDescription hierarchies are functionally the same
     * @param rhs right hand side
     * @returns True when graphs are the same
     * @note Instead compare pointers if you wish to check that they are the same instance
     */
    bool operator==(const Description& rhs) const;
    /**
     * Equality operator, checks whether AgentDescription hierarchies are functionally different
     * @param rhs right hand side
     * @returns True when graphs are not the same
     * @note Instead compare pointers if you wish to check that they are not the same instance
     */
    bool operator!=(const Description& rhs) const;

#ifndef SWIG
    /**
     * Adds a new variable to the agent
     * @param variable_name Name of the variable
     * @param default_value Default value of variable for new agents if unset, defaults to 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     */
    template<typename T>
    void newVertexProperty(const std::string& variable_name, const T& default_value = {});
    /**
     * Adds a new variable array to the agent
     * @param variable_name Name of the variable array
     * @param default_value Default value of variable for new agents if unset, defaults to each element set 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @tparam N The length of the variable array (1 if not an array, must be greater than 0)
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     * @throws exception::InvalidAgentVar If N is <= 0
     */
    template<typename T, size_type N>
    void newVertexProperty(const std::string& variable_name, const std::array<T, N>& default_value = {});
    /**
     * Adds a new variable to the agent
     * @param variable_name Name of the variable
     * @param default_value Default value of variable for new agents if unset, defaults to 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     */
    template<typename T>
    void newEdgeProperty(const std::string& variable_name, const T& default_value = {});
    /**
     * Adds a new variable array to the agent
     * @param variable_name Name of the variable array
     * @param default_value Default value of variable for new agents if unset, defaults to each element set 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @tparam N The length of the variable array (1 if not an array, must be greater than 0)
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     * @throws exception::InvalidAgentVar If N is <= 0
     */
    template<typename T, size_type N>
    void newEdgeProperty(const std::string& variable_name, const std::array<T, N>& default_value = {});
#else
    /**
     * Adds a new variable to the agent
     * @param variable_name Name of the variable
     * @param default_value Default value of variable for new agents if unset, defaults to 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     * @note Swig is unable to handle {} default param, however it's required for GLM support
     * Similarly, can't just provide 2 protoypes which overload, Python doesn't support that
     * Hence, easiest to require python users to init GLM types as arrays
     */
    template<typename T>
    void newVertexProperty(const std::string& variable_name, const T& default_value = 0);
    /**
     * Adds a new variable array to the agent
     * @param variable_name Name of the variable array
     * @param length The length of the variable array (1 if not an array, must be greater than 0)
     * @param default_value Default value of variable for new agents if unset, defaults to each element set 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     * @throws exception::InvalidAgentVar If length is <= 0
     */
    template<typename T>
    void newVertexPropertyArray(const std::string& variable_name, const ModelData::size_type& length, const std::vector<T>& default_value = {});
    /**
     * Adds a new variable to the agent
     * @param variable_name Name of the variable
     * @param default_value Default value of variable for new agents if unset, defaults to 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     * @note Swig is unable to handle {} default param, however it's required for GLM support
     * Similarly, can't just provide 2 protoypes which overload, Python doesn't support that
     * Hence, easiest to require python users to init GLM types as arrays
     */
    template<typename T>
    void newEdgeProperty(const std::string& variable_name, const T& default_value = 0);
    /**
     * Adds a new variable array to the agent
     * @param variable_name Name of the variable array
     * @param length The length of the variable array (1 if not an array, must be greater than 0)
     * @param default_value Default value of variable for new agents if unset, defaults to each element set 0
     * @tparam T Type of the agent variable, this must be an arithmetic type
     * @throws exception::InvalidAgentVar If a variable already exists within the agent with the same name
     * @throws exception::InvalidAgentVar If length is <= 0
     */
    template<typename T>
    void newEdgePropertyArray(const std::string& variable_name, const ModelData::size_type& length, const std::vector<T>& default_value = {});
#endif

    /**
     * @return The graph's name
     */
    std::string getName() const;
    /**
     * @param property_name Name used to refer to the desired property
     * @return The type of the named property
     * @throws exception::InvalidAgentVar If a property with the name does not exist within the graph
     */
    const std::type_index& getVertexPropertyType(const std::string& property_name) const;
    const std::type_index& getEdgePropertyType(const std::string& property_name) const;
    /**
     * @param property_name Name used to refer to the desired property
     * @return The size of the named property's type
     * @throws exception::InvalidAgentVar If a property with the name does not exist within the graph
     */
    size_t getVertexPropertySize(const std::string& property_name) const;
    size_t getEdgePropertySize(const std::string& property_name) const;
    /**
     * @param property_name Name used to refer to the desired property
     * @return The number of elements in the name property (1 if it isn't an array)
     * @throws exception::InvalidAgentVar If a property with the name does not exist within the graph
     */
    size_type getVertexPropertyLength(const std::string& property_name) const;
    size_type getEdgePropertyLength(const std::string& property_name) const;
    /**
     * Get the total number of variables this agent has
     * @return The total number of properties within the graph
     * @note This count includes internal properties used to track things such as ID
     */
    size_type geVertexPropertiesCount() const;
    size_type getEdgePropertiesCount() const;
    /**
     * @param property_name Name of the property to check
     * @return True when a property with the specified name exists within the graph
     */
    bool hasVertexProperty(const std::string& property_name) const;
    bool hasEdgeProperty(const std::string& property_name) const;

private:
    /**
     * Root of the model hierarchy
     */
    std::weak_ptr<const ModelData> model;
    /**
     * The class which stores all of the agent's data.
     */
    EnvironmentDirectedGraph::Data* const agent;
};
}  // namespace flamegpu

#endif  // INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDESCRIPTION_CUH_
