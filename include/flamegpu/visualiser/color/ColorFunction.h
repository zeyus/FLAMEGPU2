#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_COLORFUNCTION_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_COLORFUNCTION_H_

#include <string>

/**
 * Interface for generating shader code for a function that generates a color on the fly
 */
class ColorFunction {
 public:
    /**
     * Source should take the form of a function with the below prototype
     * vec4 calculateColor()
     */
    virtual std::string getSrc() const = 0;
    /**
     * If the shader source contains a samplerBuffer definition (e.g. of a single float/int)
     * This should be the identifier so that the buffer can be bound to it
     * Otherwise empty string
     */
    virtual std::string getSamplerName() const { return ""; }
    /**
     * If the shader source contains a samplerBuffer definition
     * This should be the name of the agent variable so that the buffer can be bound to it
     * Otherwise empty string
     */
    virtual std::string getAgentVariableName() const { return ""; }
};

#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_COLORFUNCTION_H_
