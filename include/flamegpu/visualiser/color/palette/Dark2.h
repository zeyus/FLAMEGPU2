#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_DARK2_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_DARK2_H_

#include "flamegpu/visualiser/color/StaticColor.h"
#include "flamegpu/exception/FGPUException.h"

/**
 * Color blind friendly qualitative pallete
 * Dark2 from Colorbrewer
 * @note Color names are approximations using https://www.color-blindness.com/color-name-hue/
 */
class Dark2 {
public:
    const static StaticColor ELF_GREEN, TAWNY, RICH_BLUE, RAZZMATAZZ, CHRISTI, GAMBOGE, GOLDEN_BROWN, MORTAR;
    const static std::array<StaticColor, 8> ARRAY;
    /**
     * Dark2 has 8 colors
     */
    static unsigned int getSize() { return 8; }
    /**
     * Returns the color at the given index
     * @throws OutOfBoundsException If i >= getSize()
     */
    static StaticColor at(unsigned int i)  {
        if (i == 0) return ELF_GREEN;
        if (i == 1) return TAWNY;
        if (i == 2) return RICH_BLUE;
        if (i == 3) return RAZZMATAZZ;
        if (i == 4) return CHRISTI;
        if (i == 5) return GAMBOGE;
        if (i == 6) return GOLDEN_BROWN;
        if (i == 7) return MORTAR;
        THROW OutOfBoundsException("%u is out of bounds, Dark2 palette has %u colors.\n", i, getSize());
    }
};

#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_DARK2_H_
