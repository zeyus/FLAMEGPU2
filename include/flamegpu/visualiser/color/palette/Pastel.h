#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_PASTEL_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_PASTEL_H_

#include "flamegpu/visualiser/color/StaticColor.h"
#include "flamegpu/exception/FGPUException.h"

/**
 * Qualitative palette
 * pastel palette from seaborn
 * Blue light filters may cause MACARONI_AND_CHEESE(1) and ROSEBUD(3) to appear similar
 * @note Color names are approximations using https://www.color-blindness.com/color-name-hue/
 */
class Pastel {
 public:
    static const StaticColor
        PALE_CORNFLOWER_BLUE,
        MACARONI_AND_CHEESE,
        GRANNY_SMITH_APPLE,
        ROSEBUD,
        MAUVE,
        PANCHO,
        LAVENDER_ROSE,
        VERY_LIGHT_GREY,
        CANARY,
        PALE_TURQUOISE;
    /**
     * Pastel has 10 colors
     */
    static unsigned int getSize() { return 10; }
    /**
     * Returns the color at the given index
     * @throws OutOfBoundsException If i >= getSize()
     */
    static StaticColor at(unsigned int i)  {
        if (i == 0) return PALE_CORNFLOWER_BLUE;
        if (i == 1) return MACARONI_AND_CHEESE;
        if (i == 2) return GRANNY_SMITH_APPLE;
        if (i == 3) return ROSEBUD;
        if (i == 4) return MAUVE;
        if (i == 5) return PANCHO;
        if (i == 6) return LAVENDER_ROSE;
        if (i == 7) return VERY_LIGHT_GREY;
        if (i == 8) return CANARY;
        if (i == 9) return PALE_TURQUOISE;
        THROW OutOfBoundsException("%u is out of bounds, Pastel palette has %u colors.\n", i, getSize());
    }
};

#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_PASTEL_H_
