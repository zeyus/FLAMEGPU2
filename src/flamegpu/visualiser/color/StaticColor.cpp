#include "flamegpu/visualiser/color/StaticColor.h"

#include <sstream>

#include "flamegpu/exception/FGPUException.h"

const StaticColor StaticColor::BLACK = StaticColor(0.0f, 0.0f, 0.0f);
const StaticColor StaticColor::WHITE = StaticColor(1.0f, 1.0f, 1.0f);
const StaticColor StaticColor::RED = StaticColor(1.0f, 0.0f, 0.0f);
const StaticColor StaticColor::GREEN = StaticColor(0.0f, 1.0f, 0.0f);
const StaticColor StaticColor::BLUE = StaticColor(0.0f, 0.0f, 1.0f);

constexpr StaticColor::StaticColor(const float& r, const float& g, const float& b)
    : rgba({ r, g, b, 1.0f }) {
    if (r < 0.0f || r > 1.0f) {
        THROW InvalidArgument("%f is not a valid red value, color components must be in the inclusive [0.0, 1.0]\n", r);
    }
    if (g < 0.0f || g > 1.0f) {
        THROW InvalidArgument("%f is not a valid green value, color components must be in the inclusive [0.0, 1.0]\n", g);
    }
    if (b < 0.0f || b > 1.0f) {
        THROW InvalidArgument("%f is not a valid blue value, color components must be in the inclusive [0.0, 1.0]\n", b);
    }
    if (rgba[3] < 0.0f || rgba[3] > 1.0f) {
        THROW InvalidArgument("%f is not a valid blue value, color components must be in the inclusive [0.0, 1.0]\n", rgba[3]);
    }
}
std::string StaticColor::getSrc() const {
    std::stringstream ss;
    ss << "vec4 calculateColor() {" << "\n";
    ss << "    return vec4(" << rgba[0] << ", " << rgba[1] << ", " << rgba[2] << ", " << rgba[3] << ");" << "\n";
    ss << "}" << "\n";
    return ss.str();
}
