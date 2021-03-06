#include "flamegpu/visualiser/color/StaticColor.h"

#include <sstream>
#include <cstdio>

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
StaticColor::StaticColor(const char *hex)
    : rgba(fromHEX(hex)) { }
std::string StaticColor::getSrc() const {
    std::stringstream ss;
    ss << "vec4 calculateColor() {" << "\n";
    ss << "    return vec4(" << rgba[0] << ", " << rgba[1] << ", " << rgba[2] << ", " << rgba[3] << ");" << "\n";
    ss << "}" << "\n";
    return ss.str();
}
std::array<float, 4> StaticColor::fromHEX(const char *hex) {
    // Would be nice if this got rid of sscanf, so that it could be constexpr
    if (hex[0] == '#') ++hex;
    const size_t hex_len = strlen(hex);
    if (hex_len == 6) {
        int r, g, b;
        const int ct = sscanf(hex, "%02x%02x%02x", &r, &g, &b);
        if (ct != 3) {
            THROW InvalidArgument("Unable to parse hex string '%s', "
                "in StaticColor::fromHEX().\n",
                hex);
        }
        return std::array<float, 4>{ r / 255.0f, g / 255.0f, b / 255.0f, 1.0f };
    } else if (hex_len == 3) {
        int r, g, b;
        const int ct = sscanf(hex, "%01x%01x%01x", &r, &g, &b);
        if (ct != 3) {
            THROW InvalidArgument("Unable to parse hex string '%s', "
                "in StaticColor::fromHEX().\n",
                hex);
        }
        return std::array<float, 4>{  17.0f * r / 255.0f, 17.0f * g / 255.0f,  17.0f * b / 255.0f, 1.0f };
    } else {
        THROW InvalidArgument("hex must be a string of either 3 or 6 hexidecimal characters, a length of %llu is invalid, "
            "in StaticColor::fromHEX().\n",
            hex_len);
    }
}
