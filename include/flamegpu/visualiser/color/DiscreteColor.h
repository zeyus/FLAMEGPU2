#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_DISCRETECOLOR_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_DISCRETECOLOR_H_

#include <map>
#include <string>

#include <sstream>

#include "flamegpu/exception/FGPUException.h"
#include "flamegpu/visualiser/color/ColorFunction.h"
#include "flamegpu/visualiser/color/Color.h"

struct Palette;

/**
 * Used to define a discrete color selection function
 * Integer keys are mapped to static colors
 * @note Currently ignores alpha channel of colors as Alpha support isn't properly tested
 */
template<typename T = int32_t>
class DiscreteColor : public ColorFunction, public std::map<T, Color> {
 public:
    /**
     * Constructs a discrete color function generator
     * @param variable_name Name of the agent variable which provides the integer key
     * @param fallback Color that is returned when the provided integer is not found within the map
     */
    DiscreteColor(const std::string& variable_name, const Color &fallback);

    /**
     * Constructs a discrete color function generator from a palette
     * @param variable_name Name of the agent variable which provides the integer key
     * @param palette The colors to use
     * @param fallback The color to return when they lookup doesn't have a matching int
     * @param offset The key to map to the first palette color
     * @param stride The value to added to every subsequent key
     * @see DiscreteColor(const std::string&, const Palette&, T, T);
     */
    DiscreteColor(const std::string& variable_name, const Palette& palette, const Color& fallback, T offset = 0, T stride = 1);
    /**
     * Constructs a discrete color function generator from a palette
     * This version maps the final colour of the palette to the fallback, rather than an integer key
     * @param variable_name Name of the agent variable which provides the integer key
     * @param palette The colors to use
     * @param offset The key to map to the first palette color
     * @param stride The value to added to every subsequent key
     * @see DiscreteColor(const std::string&, const Palette&, const Color&, T, T);
     */
    DiscreteColor(const std::string& variable_name, const Palette& palette, T offset = 0, T stride = 1);

    /**
     * Returns a function containing a switch statement through the entries of the map:
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
