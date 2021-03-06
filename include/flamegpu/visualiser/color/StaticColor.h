#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_STATICCOLOR_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_STATICCOLOR_H_

#include <array>
#include <string>

#include "flamegpu/visualiser/color/ColorFunction.h"
#include "flamegpu/visualiser/color/Color.h"

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
     * Constructs a static color function generator
     * All components must be provided in the inclusive range [0.0, 1.0]
     * @param rgba Color to represent
     */
    explicit constexpr StaticColor(const Color &rgba);
    /**
     * Returns a function returning a constant color in the form:
     * vec4 calculateColor() {
     *   return vec4(1.0, 0.0, 0.0, 1.0);
     * }
     */
    std::string getSrc() const override;

 private:
    /**
     * Shader controls RGBA values, but currently we only expose RGB (A support is somewhat untested)
     */
    Color rgba;
};

#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_STATICCOLOR_H_
