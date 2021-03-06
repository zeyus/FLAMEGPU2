#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_STATICCOLOR_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_STATICCOLOR_H_

#include <array>
#include <string>

#include "flamegpu/visualiser/color/ColorFunction.h"

/**
 * Creates a color function returning a static color
 */
class StaticColor : public ColorFunction {
 public:
     static const StaticColor BLACK;
     static const StaticColor WHITE;
     static const StaticColor RED;
     static const StaticColor GREEN;
     static const StaticColor BLUE;
    /**
     * Constructs a static colorfunction generator
     * All components must be provided in the inclusive range [0.0, 1.0]
     * @param r Red value
     * @param g Green value
     * @param b Blue value
     */
    constexpr StaticColor(const float& r, const float& g, const float& b);
    /**
     * Constructs a static colorfunction generator from a 3 or 6 char hexcode
     * Optional the hexcode may begin with '#'
     */
    explicit StaticColor(const char *hexcode);
    /**
     * Returns a function returning a constant color in the form:
     * vec4 calculateColor() {
     *   return vec4(1.0, 0.0, 0.0, 1.0);
     * }
     */
    std::string getSrc() const override;

 private:
    std::array<float, 4> fromHEX(const char hex[3]);
    /**
     * Shader controls RGBA values, but currently we only expose RGB (A support is somewhat untested)
     */
    const std::array<float, 4> rgba;
};

#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_STATICCOLOR_H_
