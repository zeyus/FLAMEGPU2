#include "flamegpu/model/EnvironmentDescription.h"
#include "flamegpu/runtime/environment/EnvironmentDirectedGraph/EnvironmentDirectedGraphData.cuh"

namespace flamegpu {

EnvironmentDescription::EnvironmentDescription() {
    // Add CUDASimulation specific environment members
    // We do this here, to not break comparing different model description hierarchies before/after CUDASimulation creation
    const unsigned int zero = 0;
    newProperty("_stepCount", reinterpret_cast<const char*>(&zero), sizeof(unsigned int), false, 1, typeid(unsigned int));
}
EnvironmentDescription::EnvironmentDescription(const EnvironmentDescription& other)
    : properties(other.properties)
    , macro_properties(other.macro_properties) {
    for (const auto g : other.directed_graphs) {
        auto t = std::shared_ptr<EnvironmentDirectedGraph::Data>(new EnvironmentDirectedGraph::Data(*g.second));
        directed_graphs.emplace(g.first, t);
    }
}
EnvironmentDescription &EnvironmentDescription::operator=(const EnvironmentDescription& other) {
    properties = std::unordered_map(other.properties);
    macro_properties = std::unordered_map(other.macro_properties);
    directed_graphs.clear();
    for (const auto g : other.directed_graphs) {
        auto t = std::shared_ptr<EnvironmentDirectedGraph::Data>(new EnvironmentDirectedGraph::Data(*g.second));
        directed_graphs.emplace(g.first, t);
    }
    return *this;
}
EnvironmentDirectedGraph::Description& EnvironmentDescription::newDirectedGraph(const std::string& graph_name) {
    if (directed_graphs.find(graph_name) == directed_graphs.end()) {
        auto t = std::shared_ptr<EnvironmentDirectedGraph::Data>(new EnvironmentDirectedGraph::Data(graph_name));
        directed_graphs.emplace(graph_name, t);
        return *t->description;
    }
    THROW exception::InvalidGraphName("Directed graph with name '%s' already exists, "
        "in EnvironmentDescription::newDirectedGraph().",
        graph_name.c_str());
}

bool EnvironmentDescription::operator==(const EnvironmentDescription& rhs) const {
    if (this == &rhs)  // They point to same object
        return true;
    if (properties.size() == rhs.properties.size()) {
        for (auto &v : properties) {
            auto _v = rhs.properties.find(v.first);
            if (_v == rhs.properties.end())
                return false;
            if (v.second != _v->second)
                return false;
        }
        return true;
    }
    if (macro_properties.size() == rhs.macro_properties.size()) {
        for (auto& v : macro_properties) {
            auto _v = rhs.macro_properties.find(v.first);
            if (_v == rhs.macro_properties.end())
                return false;
            if (v.second != _v->second)
                return false;
        }
        return true;
    }
    if (directed_graphs.size() == rhs.directed_graphs.size()) {
        for (auto& v : directed_graphs) {
            auto _v = rhs.directed_graphs.find(v.first);
            if (_v == rhs.directed_graphs.end())
                return false;
            if (v.second != _v->second)
                return false;
        }
        return true;
    }
    return false;
}
bool EnvironmentDescription::operator!=(const EnvironmentDescription& rhs) const {
    return !(*this == rhs);
}

void EnvironmentDescription::newProperty(const std::string &name, const char *ptr, size_t length, bool isConst, EnvironmentManager::size_type elements, const std::type_index &type) {
    properties.emplace(name, PropData(isConst, util::Any(ptr, length, type, elements)));
}

bool EnvironmentDescription::getConst(const std::string &name) {
    for (auto &i : properties) {
        if (i.first == name) {
            return i.second.isConst;
        }
    }
    THROW exception::InvalidEnvProperty("Environmental property with name '%s' does not exist, "
        "in EnvironmentDescription::getConst().",
        name.c_str());
}

const std::unordered_map<std::string, EnvironmentDescription::PropData> EnvironmentDescription::getPropertiesMap() const {
    return properties;
}
const std::unordered_map<std::string, EnvironmentDescription::MacroPropData> EnvironmentDescription::getMacroPropertiesMap() const {
    return macro_properties;
}

}  // namespace flamegpu
