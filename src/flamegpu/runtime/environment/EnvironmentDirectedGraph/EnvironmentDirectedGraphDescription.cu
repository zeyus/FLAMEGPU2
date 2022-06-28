#include "flamegpu/runtime/environment/EnvironmentDirectedGraph/EnvironmentDirectedGraphDescription.cuh"
namespace flamegpu {

EnvironmentDirectedGraph::Description::Description(std::shared_ptr<const ModelData> _model, Data* const data)
    : model(_model)
    , graph(data) { }
bool EnvironmentDirectedGraph::Description::operator==(const Description & rhs) const {
    return *this->graph == *rhs.graph;  // Compare content is functionally the same
}
bool EnvironmentDirectedGraph::Description::operator!=(const Description & rhs) const {
    return !(*this == rhs);
}
std::string EnvironmentDirectedGraph::Description::getName() const {
    return graph->name;
}

/**
 * Const Accessors
 */
const std::type_index& EnvironmentDirectedGraph::Description::getVertexPropertyType(const std::string& property_name) const {
    const auto f = graph->vertexProperties.find(property_name);
    if (f != graph->vertexProperties.end()) {
        return f->second.type;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') does not contain vertex property '%s', "
        "in EnvironmentDirectedGraph::Description::getVertexPropertyType().",
        graph->name.c_str(), property_name.c_str());
}
const std::type_index& EnvironmentDirectedGraph::Description::getEdgePropertyType(const std::string& property_name) const {
    const auto f = graph->edgeProperties.find(property_name);
    if (f != graph->edgeProperties.end()) {
        return f->second.type;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') does not contain edge property '%s', "
        "in EnvironmentDirectedGraph::Description::getEdgePropertyType().",
        graph->name.c_str(), property_name.c_str());
}

size_t EnvironmentDirectedGraph::Description::getVertexPropertySize(const std::string& property_name) const {
    const auto f = graph->vertexProperties.find(property_name);
    if (f != graph->vertexProperties.end()) {
        return f->second.type_size;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') does not contain vertex property '%s', "
        "in EnvironmentDirectedGraph::Description::getVertexPropertySize().",
        graph->name.c_str(), property_name.c_str());
}
size_t EnvironmentDirectedGraph::Description::getEdgePropertySize(const std::string& property_name) const {
    const auto f = graph->edgeProperties.find(property_name);
    if (f != graph->edgeProperties.end()) {
        return f->second.type_size;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') does not contain edge property '%s', "
        "in EnvironmentDirectedGraph::Description::getEdgePropertySize().",
        graph->name.c_str(), property_name.c_str());
}

EnvironmentDirectedGraph::size_type EnvironmentDirectedGraph::Description::getVertexPropertyLength(const std::string& property_name) const {
    const auto f = graph->vertexProperties.find(property_name);
    if (f != graph->vertexProperties.end()) {
        return f->second.elements;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') does not contain vertex property '%s', "
        "in EnvironmentDirectedGraph::Description::getVertexPropertyLength().",
        graph->name.c_str(), property_name.c_str());
}
EnvironmentDirectedGraph::size_type EnvironmentDirectedGraph::Description::getEdgePropertyLength(const std::string& property_name) const {
    const auto f = graph->edgeProperties.find(property_name);
    if (f != graph->edgeProperties.end()) {
        return f->second.elements;
    }
    THROW exception::InvalidGraphProperty("Graph ('%s') does not contain edge property '%s', "
        "in EnvironmentDirectedGraph::Description::getEdgePropertyLength().",
        graph->name.c_str(), property_name.c_str());
}

EnvironmentDirectedGraph::size_type EnvironmentDirectedGraph::Description::geVertexPropertiesCount() const {
    // Downcast, will never have more than UINT_MAX VARS
    return static_cast<ModelData::size_type>(graph->vertexProperties.size());
}
EnvironmentDirectedGraph::size_type EnvironmentDirectedGraph::Description::getEdgePropertiesCount() const {
    // Downcast, will never have more than UINT_MAX VARS
    return static_cast<ModelData::size_type>(graph->edgeProperties.size());
}

bool EnvironmentDirectedGraph::Description::hasVertexProperty(const std::string& property_name) const {
    return graph->vertexProperties.find(property_name) != graph->vertexProperties.end();
}
bool EnvironmentDirectedGraph::Description::hasEdgeProperty(const std::string& property_name) const {
    return graph->edgeProperties.find(property_name) != graph->edgeProperties.end();
}

}  // namespace flamegpu
