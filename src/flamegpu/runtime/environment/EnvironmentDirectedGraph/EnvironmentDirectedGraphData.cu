#include "flamegpu/runtime/environment/EnvironmentDirectedGraph/EnvironmentDirectedGraphData.cuh"
#include "flamegpu/runtime/environment/EnvironmentDirectedGraph/EnvironmentDirectedGraphDescription.cuh"

namespace flamegpu {

EnvironmentDirectedGraph::Data::Data(const std::string& agent_name)
    : description(new Description(this))
    , name(agent_name) {
    // Not currently any default properties
}
EnvironmentDirectedGraph::Data::Data(const Data& other)
    : vertexProperties(other.vertexProperties)
    , edgeProperties(other.edgeProperties)
    , description(new Description(this))
    , name(other.name) { }
std::shared_ptr<const EnvironmentDirectedGraph::Data> EnvironmentDirectedGraph::Data::clone() const {
    return std::shared_ptr<Data>(new Data(*this));
}
bool EnvironmentDirectedGraph::Data::operator==(const Data& rhs) const {
    if (name == rhs.name
        && vertexProperties.size() == rhs.vertexProperties.size()
        && edgeProperties.size() == rhs.edgeProperties.size()) {
        {  // Compare vertex properties
            for (auto& v : vertexProperties) {
                auto _v = rhs.vertexProperties.find(v.first);
                if (_v == rhs.vertexProperties.end())
                    return false;
                if (v.second.type_size != _v->second.type_size || v.second.type != _v->second.type || v.second.elements != _v->second.elements)
                    return false;
            }
        }
        {  // Compare edge properties
            for (auto& v : edgeProperties) {
                auto _v = rhs.edgeProperties.find(v.first);
                if (_v == rhs.edgeProperties.end())
                    return false;
                if (v.second.type_size != _v->second.type_size || v.second.type != _v->second.type || v.second.elements != _v->second.elements)
                    return false;
            }
        }
        return true;
    }
    return false;
}
bool EnvironmentDirectedGraph::Data::operator!=(const Data& rhs) const {
    return !operator==(rhs);
}

}  // namespace flamegpu
