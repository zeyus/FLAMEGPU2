#include "flamegpu/visualiser/color/DiscreteColor.h"

#include "flamegpu/visualiser/color/StaticColor.h"


template<typename T>
DiscreteColor<T>::DiscreteColor(const std::string& _variable_name, const Color& _fallback)
    : std::map<T, Color>()
    , fallback(_fallback)
    , variable_name(_variable_name) { }

template<typename T>
std::string DiscreteColor<T>::getSamplerName() const {
    return "color_arg";
}
template<typename T>
std::string DiscreteColor<T>::getAgentVariableName() const {
    return variable_name;
}

template<typename T>
bool DiscreteColor<T>::validate() const {
    if (!fallback.validate())
        return false;
    for (const auto& m : *this)
        if (!m.second.validate())
            return false;
    return true;
}

// Force instantiate the 2 supported types
template class DiscreteColor<int32_t>;
template class DiscreteColor<uint32_t>;
