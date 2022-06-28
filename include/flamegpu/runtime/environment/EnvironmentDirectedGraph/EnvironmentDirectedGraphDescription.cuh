#ifndef INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDESCRIPTION_CUH_
#define INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDESCRIPTION_CUH_

#include <vector>
#include <memory>
#include <string>

#include "flamegpu/runtime/environment/EnvironmentDirectedGraph/EnvironmentDirectedGraphData.cuh"
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
    friend struct Data;
    /**
     * Only way to construct an graphDescription
     */
    friend EnvironmentDirectedGraph::Description& EnvironmentDescription::newDirectedGraph(const std::string&);

    /**
     * Constructor, this should only be called by EnvironmentDirectedGraph::Data
     * @param _model Model at root of model hierarchy
     * @param data Data store of this graph's data
     */
    Description(std::shared_ptr<const ModelData> _model, EnvironmentDirectedGraph::Data* const data);
    /**
     * Default copy constructor, not implemented
     */
    Description(const Description& other_graph) = delete;
    /**
     * Default move constructor, not implemented
     */
    Description(Description&& other_graph) noexcept = delete;
    /**
     * Default copy assignment, not implemented
     */
    Description& operator=(const Description& other_graph) = delete;
    /**
     * Default move assignment, not implemented
     */
    Description& operator=(Description&& other_graph) noexcept = delete;

 public:
    /**
     * Equality operator, checks whether graphDescription hierarchies are functionally the same
     * @param rhs right hand side
     * @returns True when graphs are the same
     * @note Instead compare pointers if you wish to check that they are the same instance
     */
    bool operator==(const Description& rhs) const;
    /**
     * Equality operator, checks whether graphDescription hierarchies are functionally different
     * @param rhs right hand side
     * @returns True when graphs are not the same
     * @note Instead compare pointers if you wish to check that they are not the same instance
     */
    bool operator!=(const Description& rhs) const;

    /**
     * Adds a new property array to the graph
     * @param property_name Name of the vertex property array
     * @param default_value Default value of vertex property for vertex if unset, defaults to each element set 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @tparam N The length of the property array (1 if not an array, must be greater than 0)
     * @throws exception::InvalidGraphProperty If a property already exists within the graph with the same name
     * @throws exception::InvalidGraphProperty If N is <= 0
     */
    template<typename T, size_type N>
    void newVertexProperty(const std::string& property_name, const std::array<T, N>& default_value = {});
    /**
     * Adds a new property array to the graph
     * @param property_name Name of the property array
     * @param default_value Default value of edge property for edges if unset, defaults to each element set 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @tparam N The length of the property array (1 if not an array, must be greater than 0)
     * @throws exception::InvalidGraphProperty If a property already exists within the graph with the same name
     * @throws exception::InvalidGraphProperty If N is <= 0
     */
    template<typename T, size_type N>
    void newEdgeProperty(const std::string& property_name, const std::array<T, N>& default_value = {});
#ifndef SWIG
    /**
     * Adds a new property to the graph
     * @param property_name Name of the property
     * @param default_value Default value of vertex property for vertices if unset, defaults to 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @throws exception::InvalidGraphProperty If a property already exists within the graph with the same name
     */
    template<typename T>
    void newVertexProperty(const std::string& property_name, const T& default_value = {});
    /**
     * Adds a new property to the graph
     * @param property_name Name of the property
     * @param default_value Default value of edge property for edges if unset, defaults to 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @throws exception::InvalidGraphProperty If a property already exists within the graph with the same name
     */
    template<typename T>
    void newEdgeProperty(const std::string& property_name, const T& default_value = {});
#else
    /**
     * Adds a new vertex property to the graph
     * @param property_name Name of the property
     * @param default_value Default value of edge property for vertices where unset, defaults to 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @throws exception::InvalidGraphProperty If a property already exists within the graph with the same name
     * @note Swig is unable to handle {} default param, however it's required for GLM support
     * Similarly, can't just provide 2 protoypes which overload, Python doesn't support that
     * Hence, easiest to require python users to init GLM types as arrays
     */
    template<typename T>
    void newVertexProperty(const std::string& property_name, const T& default_value = 0);
    /**
     * Adds a new vertex property array to the graph
     * @param property_name Name of the edge property array
     * @param length The length of the edge property array (1 if not an array, must be greater than 0)
     * @param default_value Default value of property for vertices if unset, defaults to each element set 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @throws exception::InvalidGraphProperty If a edge property already exists within the graph with the same name
     * @throws exception::InvalidGraphProperty If length is <= 0
     */
    template<typename T>
    void newVertexPropertyArray(const std::string& property_name, size_type length, const std::vector<T>& default_value = {});
    /**
     * Adds a new edge property to the graph
     * @param property_name Name of the property
     * @param default_value Default value of edge property for edges if unset, defaults to 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @throws exception::InvalidGraphProperty If a property already exists within the graph with the same name
     * @note Swig is unable to handle {} default param, however it's required for GLM support
     * Similarly, can't just provide 2 protoypes which overload, Python doesn't support that
     * Hence, easiest to require python users to init GLM types as arrays
     */
    template<typename T>
    void newEdgeProperty(const std::string& property_name, const T& default_value = 0);
    /**
     * Adds a new edge_property array to the graph
     * @param property_name Name of the edge property array
     * @param length The length of the edge property array (1 if not an array, must be greater than 0)
     * @param default_value Default value of edge property for edges if unset, defaults to each element set 0
     * @tparam T Type of the graph property, this must be an arithmetic type
     * @throws exception::InvalidGraphProperty If a property already exists within the graph with the same name
     * @throws exception::InvalidGraphProperty If length is <= 0
     */
    template<typename T>
    void newEdgePropertyArray(const std::string& property_name, size_type length, const std::vector<T>& default_value = {});
#endif

    /**
     * @return The graph's name
     */
    std::string getName() const;
    /**
     * @param property_name Name used to refer to the desired property
     * @return The type of the named property
     * @throws exception::InvalidGraphProperty If a property with the name does not exist within the graph
     */
    const std::type_index& getVertexPropertyType(const std::string& property_name) const;
    const std::type_index& getEdgePropertyType(const std::string& property_name) const;
    /**
     * @param property_name Name used to refer to the desired property
     * @return The size of the named property's type
     * @throws exception::InvalidGraphProperty If a property with the name does not exist within the graph
     */
    size_t getVertexPropertySize(const std::string& property_name) const;
    size_t getEdgePropertySize(const std::string& property_name) const;
    /**
     * @param property_name Name used to refer to the desired property
     * @return The number of elements in the name property (1 if it isn't an array)
     * @throws exception::InvalidGraphProperty If a property with the name does not exist within the graph
     */
    size_type getVertexPropertyLength(const std::string& property_name) const;
    size_type getEdgePropertyLength(const std::string& property_name) const;
    /**
     * Get the total number of propertys this graph has
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
     * The class which stores all of the graph's data.
     */
    EnvironmentDirectedGraph::Data* const graph;
};

template<typename T>
void EnvironmentDirectedGraph::Description::newVertexProperty(const std::string& property_name, const T& default_value) {
    newVertexProperty<T, 1>(property_name, { default_value });
}
template<typename T, EnvironmentDirectedGraph::size_type N>
void EnvironmentDirectedGraph::Description::newVertexProperty(const std::string& property_name, const std::array<T, N>& default_value) {
    if (!property_name.empty() && property_name[0] == '_') {
        THROW exception::ReservedName("Graph property names cannot begin with '_', this is reserved for internal usage, "
            "in EnvironmentDirectedGraph::Description::newVertexProperty().");
    }
    // Array length 0 makes no sense
    static_assert(type_decode<T>::len_t * N > 0, "A property cannot have 0 elements.");
    if (graph->vertexProperties.find(property_name) == graph->vertexProperties.end()) {
        const std::array<typename type_decode<T>::type_t, type_decode<T>::len_t* N>* casted_default =
            reinterpret_cast<const std::array<typename type_decode<T>::type_t, type_decode<T>::len_t* N>*>(&default_value);
        graph->vertexProperties.emplace(property_name, property(*casted_default));
        return;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') already contains vertex property '%s', "
        "in EnvironmentDirectedGraph::Description::newVertexProperty().",
        graph->name.c_str(), property_name.c_str());
}
template<typename T>
void EnvironmentDirectedGraph::Description::newEdgeProperty(const std::string& property_name, const T& default_value) {
    newEdgeProperty<T, 1>(property_name, { default_value });
}
template<typename T, EnvironmentDirectedGraph::size_type N>
void EnvironmentDirectedGraph::Description::newEdgeProperty(const std::string& property_name, const std::array<T, N>& default_value) {
    if (!property_name.empty() && property_name[0] == '_') {
        THROW exception::ReservedName("Graph property names cannot begin with '_', this is reserved for internal usage, "
            "in EnvironmentDirectedGraph::Description::newEdgeProperty().");
    }
    // Array length 0 makes no sense
    static_assert(type_decode<T>::len_t * N > 0, "A property cannot have 0 elements.");
    if (graph->edgeProperties.find(property_name) == graph->edgeProperties.end()) {
        const std::array<typename type_decode<T>::type_t, type_decode<T>::len_t* N>* casted_default =
            reinterpret_cast<const std::array<typename type_decode<T>::type_t, type_decode<T>::len_t* N>*>(&default_value);
        graph->edgeProperties.emplace(property_name, property(*casted_default));
        return;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') already contains edge property '%s', "
        "in EnvironmentDirectedGraph::Description::newEdgeProperty().",
        graph->name.c_str(), property_name.c_str());
}
#ifdef SWIG
template<typename T>
void EnvironmentDirectedGraph::Description::newVertexPropertyArray(const std::string& property_name, const size_type length, const std::vector<T>& default_value) {
    if (!property_name.empty() && property_name[0] == '_') {
        THROW exception::ReservedName("Graph property names cannot begin with '_', this is reserved for internal usage, "
            "in EnvironmentDirectedGraph::Description::newVertexPropertyArray().");
    }
    if (length == 0) {
        THROW exception::InvalidGraphProperty("Graph property arrays must have a length greater than 0."
            "in EnvironmentDirectedGraph::Description::newVertexPropertyArray().");
    }
    if (default_value.size() && default_value.size() != length) {
        THROW exception::InvalidGraphProperty("Graph vertex property array length specified as %d, but default value provided with %llu elements, "
            "in EnvironmentDirectedGraph::Description::newVertexPropertyArray().",
            length, static_cast<unsigned int>(default_value.size()));
    }
    if (graph->vertexProperties.find(property_name) == graph->vertexProperties.end()) {
        std::vector<typename type_decode<T>::type_t> temp(static_cast<size_t>(type_decode<T>::len_t * length));
        if (default_value.size()) {
            memcpy(temp.data(), default_value.data(), sizeof(typename type_decode<T>::type_t) * type_decode<T>::len_t * length);
        }
        graph->vertexProperties.emplace(property_name, property(type_decode<T>::len_t * length, temp));
        return;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') already contains vertex property '%s', "
        "in EnvironmentDirectedGraph::Description::newVertexPropertyArray().",
        graph->name.c_str(), property_name.c_str());
}
template<typename T>
void EnvironmentDirectedGraph::Description::newEdgePropertyArray(const std::string& property_name, const size_type length, const std::vector<T>& default_value) {
    if (!property_name.empty() && property_name[0] == '_') {
        THROW exception::ReservedName("Graph property names cannot begin with '_', this is reserved for internal usage, "
            "in EnvironmentDirectedGraph::Description::newEdgePropertyArray().");
    }
    if (length == 0) {
        THROW exception::InvalidGraphProperty("Graph property arrays must have a length greater than 0."
            "in EnvironmentDirectedGraph::Description::newEdgePropertyArray().");
    }
    if (default_value.size() && default_value.size() != length) {
        THROW exception::InvalidGraphProperty("Graph vertex property array length specified as %d, but default value provided with %llu elements, "
            "in EnvironmentDirectedGraph::Description::newEdgePropertyArray().",
            length, static_cast<unsigned int>(default_value.size()));
    }
    if (graph->edgeProperties.find(property_name) == graph->edgeProperties.end()) {
        std::vector<typename type_decode<T>::type_t> temp(static_cast<size_t>(type_decode<T>::len_t * length));
        if (default_value.size()) {
            memcpy(temp.data(), default_value.data(), sizeof(typename type_decode<T>::type_t) * type_decode<T>::len_t * length);
        }
        graph->edgeProperties.emplace(property_name, property(type_decode<T>::len_t * length, temp));
        return;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') already contains edge property '%s', "
        "in EnvironmentDirectedGraph::Description::newEdgePropertyArray().",
        graph->name.c_str(), property_name.c_str());
}
#endif

}  // namespace flamegpu

#endif  // INCLUDE_FLAMEGPU_RUNTIME_ENVIRONMENT_ENVIRONMENTDIRECTEDGRAPH_ENVIRONMENTDIRECTEDGRAPHDESCRIPTION_CUH_
