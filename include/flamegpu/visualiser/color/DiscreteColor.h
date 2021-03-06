#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_DISCRETECOLOR_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_DISCRETECOLOR_H_

#include <map>
#include <string>
#include <array>


#include <sstream>

#include "flamegpu/exception/FGPUException.h"
#include "flamegpu/visualiser/color/ColorFunction.h"
#include "flamegpu/visualiser/color/Color.h"

/**
 * Used to define a discrete color selection function
 * Integer keys are mapped to static colors
 * @note Currently ignores alpha channel of colors as Alpha support isn't properly tested
 */
template<typename T = int32_t>
class DiscreteColor : public ColorFunction, public std::map<T, Color> {
 public:
    /**
     * Constructs a static color
     * All components must be provided in the inclusive range [0.0, 1.0]
     * @param variable_name Name of the agent variable which maps to hue, the variable type must be float
     * @param fallback Color that is returned when the provided integer is not found within the map
     */
    DiscreteColor(const std::string& variable_name, const Color &fallback);

    /**
     * From Palette, todo
     */
    // DiscreteColor(const Palette& palette, int offset = 0);

    /**
     * Returns a function returning a constant color in the form:
     * vec4 calculateColor() {
     *   return vec4(1.0, 0.0, 0.0, 1.0);
     * }
     */
    std::string getSrc() const override;
    /**
     * Always returns "color_arg"
     */
    std::string getSamplerName() const override;
    /**
     * Returns variable_name
     */
    std::string getAgentVariableName() const override;

    /**
     * Return false if any contained colors are invalid
     */
    bool validate() const;

 private:
    Color fallback;
    /**
     * Value returned by getAgentVariableName()
     */
    const std::string variable_name;
};
typedef DiscreteColor<uint32_t> uDiscreteColor;
typedef DiscreteColor<int32_t> iDiscreteColor;
// Define this here, so the static assert can give a better compile error for unwanted template instantiations
template<typename T>
std::string DiscreteColor<T>::getSrc() const {
    static_assert(std::is_same<T, int32_t>::value || std::is_same<T, uint32_t>::value, "T must be of type int32_t or uint32_t");
    // Validate colors
    if (!validate()) {
        THROW InvalidOperation("DiscreteColor contains invalid color!");
    }
    std::stringstream ss;
    ss << "uniform samplerBuffer color_arg;" << "\n";
    ss << "vec4 calculateColor() {" << "\n";
    // Fetch discrete value
    if (std::is_same<T, int32_t>::value) {
        ss << "    const int category = floatBitsToInt(texelFetch(color_arg, gl_InstanceID).x);" << "\n";
    } else if (std::is_same<T, uint32_t>::value) {
        ss << "    const unsigned int category = floatBitsToUint(texelFetch(color_arg, gl_InstanceID).x);" << "\n";
    }
    // Select the desired color
    ss << "    switch (category) {" << "\n";
    for (const auto& m : *this)
        ss << "      case " << m.first << ": return vec4(" << m.second[0] << ", " << m.second[1] << ", " << m.second[2] << ", 1);" << "\n";
    // Fallback value
    ss << "      default: return vec4(" << fallback[0] << ", " << fallback[1] << ", " << fallback[2] << ", 1);" << "\n";
    ss << "    }" << "\n";
    ss << "}" << "\n";
    return ss.str();
}
#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_DISCRETECOLOR_H_
