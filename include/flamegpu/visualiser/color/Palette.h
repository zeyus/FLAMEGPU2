#ifndef INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_H_
#define INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_H_

#include <iterator>
#include <vector>

#include "flamegpu/visualiser/color/Color.h"

struct Palette {
    class const_iterator : public std::iterator<std::input_iterator_tag, const Color> {
        const Palette& palette;
        difference_type pos;
     public:
        const_iterator(const Palette& _palette, difference_type _pos)
            : palette(_palette), pos(_pos) { }
        const_iterator& operator++() { ++pos; return *this; }
        const_iterator operator++(int) { const_iterator retval = *this; ++(*this); return retval; }
        bool operator==(const_iterator other) const {
            return pos == other.pos && palette == other.palette;
        }
        bool operator!=(const_iterator other) const { return !(*this == other); }
        const Color& operator*() const { return palette[pos]; }
    };
    virtual ~Palette() = default;
    const Color& operator[](size_t i) const { return colors()[i]; }
    size_t size() const { return colors().size(); }
    const_iterator begin() const {return const_iterator(*this, 0); }
    const_iterator end() const { return const_iterator(*this, size()); }
    bool operator==(const Palette& other) const {
        if (size() != other.size())
            return false;
        for (unsigned int i = 0; i < size(); ++i)
            if ((*this)[i] != other[i])
                return false;
        return true;
    }
    virtual const std::vector<Color>& colors() const = 0;
};

namespace Stock {
namespace Palette {
/**
 * Color blind friendly qualitative palette
 * Dark2 from Colorbrewer
 * @note Color names are approximations using https://www.color-blindness.com/color-name-hue/
 */
struct Dark2 : Palette {
    const std::vector<Color>& colors() const override {
        static auto colors = std::vector<Color>{
            Color("1D8F64"),
            Color("CE4A08"),
            Color("6159A4"),
            Color("DE0077"),
            Color("569918"),
            Color("DF9C09"),
            Color("946317"),
            Color("535353"),
        };
        return colors;
    }
    enum Name {
        ELF_GREEN,
        TAWNY,
        RICH_BLUE,
        RAZZMATAZZ,
        CHRISTI,
        GAMBOGE,
        GOLDEN_BROWN,
        MORTAR,
    };
};
/**
 * Qualitative palette
 * pastel palette from seaborn
 * Blue light filters may cause MACARONI_AND_CHEESE(1) and ROSEBUD(3) to appear similar
 * @note Color names are approximations using https://www.color-blindness.com/color-name-hue/
 */
struct Pastel : Palette {
    const std::vector<Color>& colors() const override {
        static auto colors = std::vector<Color>{
            Color("A1C9F4"),
            Color("FFB482"),
            Color("8DE5A1"),
            Color("FF9F9B"),
            Color("D0BBFF"),
            Color("DEBB9B"),
            Color("FAB0E4"),
            Color("CFCFCF"),
            Color("FFFEA3"),
            Color("B9F2F0"),
        };
        return colors;
    }
    enum Name {
        PALE_CORNFLOWER_BLUE,
        MACARONI_AND_CHEESE,
        GRANNY_SMITH_APPLE,
        ROSEBUD,
        MAUVE,
        PANCHO,
        LAVENDER_ROSE,
        VERY_LIGHT_GREY,
        CANARY,
        PALE_TURQUOISE,
    };
};
/**
 * Qualitative Instances
 */
static const Dark2 DARK2;
static const Pastel PASTEL;
/**
 * Sequential Instances
 */
/**
 * Diverging Instances
 */
}  // namespace Palette
}  // namespace Stock

#endif  // INCLUDE_FLAMEGPU_VISUALISER_COLOR_PALETTE_H_
