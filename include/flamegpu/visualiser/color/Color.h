#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_COLOR_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_COLOR_H_

#include <cstring>
#include <array>

#include "flamegpu/exception/FGPUException.h"

/**
 * Store for a floating point rgba color
 * Each component should be in the inclusive range [0, 1]
 */
struct Color {
    float r, g, b, a;
    Color()
        : r(1.0f), g(1.0f), b(1.0f), a(1.0f) { }
    Color(float _r, float _g, float _b, float _a = 1.0f)
        : r(_r), g(_g), b(_b), a(_a) { }
    Color(int _r, int _g, int _b, int _a = 255)
        : r(_r / 255.0f), g(_g / 255.0f), b(_b / 255.0f), a(_a / 255.0f) { }
    explicit Color(const std::array<float, 3>& rgb)
        : r(rgb[0]), g(rgb[1]), b(rgb[2]), a(1.0f) { }
    explicit Color(const std::array<float, 4>& rgba)
        : r(rgba[0]), g(rgba[1]), b(rgba[2]), a(rgba[3]) { }
    explicit Color(const std::array<int, 3> &rgb)
        : r(rgb[0] / 255.0f), g(rgb[1] / 255.0f), b(rgb[2] / 255.0f), a(1.0f) { }
    explicit Color(const std::array<int, 4>& rgba)
        : r(rgba[0] / 255.0f), g(rgba[1] / 255.0f), b(rgba[2] / 255.0f), a(rgba[3] / 255.0f) { }
    explicit Color(const char* hex) { *this = hex; }
    Color& operator=(const char *hex) {
        a = 1.0f;
        // Would be nice to get rid of sscanf, so that it could be constexpr
        if (hex[0] == '#') ++hex;
        const size_t hex_len = strlen(hex);
        if (hex_len == 8) {
            int _r, _g, _b, _a;
            const int ct = sscanf(hex, "%02x%02x%02x%02x", &_r, &_g, &_b, &_a);
            if (ct == 4) {
                r = _r / 255.0f; g = _g / 255.0f; b = _b / 255.0f; a = _a / 255.0f;
                return *this;
            }
        } else if (hex_len == 6) {
            int _r, _g, _b;
            const int ct = sscanf(hex, "%02x%02x%02x", &_r, &_g, &_b);
            if (ct == 3) {
                r = _r / 255.0f; g = _g / 255.0f; b = _b / 255.0f;
                return *this;
            }
        } else if (hex_len == 4) {
            int _r, _g, _b, _a;
            const int ct = sscanf(hex, "%01x%01x%01x%01x", &_r, &_g, &_b, &_a);
            if (ct == 4) {
                r = 17.0f * _r / 255.0f; g = 17.0f * _g / 255.0f; b = 17.0f * _b / 255.0f; a = 17.0f * _a / 255.0f;
                return *this;
            }
        } else if (hex_len == 3) {
            int _r, _g, _b;
            const int ct = sscanf(hex, "%01x%01x%01x", &_r, &_g, &_b);
            if (ct == 3) {
                r = 17.0f * _r / 255.0f; g = 17.0f * _g / 255.0f; b = 17.0f * _b / 255.0f;
                return *this;
            }
        }
        THROW InvalidArgument("Unable to parse hex string '%s', must be a string of either 3, 4, 6 or 8 hexidecimal characters, "
            "in Color::Color().\n",
            hex);
    }
    float& operator[](unsigned int index) {
        if (index >= 4) {
            THROW InvalidArgument("index '%u' is not in the inclusive range [0, 3], "
                "in Color::operator[]().\n",
                index);
        }
        return (&r)[index];
    }
    float operator[](unsigned int index) const {
        if (index >= 4) {
            THROW InvalidArgument("index '%u' is not in the inclusive range [0, 3], "
                "in Color::operator[]().\n",
                index);
        }
        return (&r)[index];
    }
    bool validate() const {
        for (unsigned int i = 0; i < 4; ++i)
            if ((&r)[i] < 0.0f || ((&r)[i] > 1.0f))
                return false;
        return true;
    }
    bool operator==(const Color &other) const {
        if (r != other.r ||
            g != other.g ||
            b != other.b ||
            a != other.a)
                return false;
        return true;
    }
    bool operator!=(const Color& other) const {
        return !(*this == other);
    }
};

#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_COLOR_H_
