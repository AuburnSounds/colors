/**
* This module defines "standard" colorspace compatible with typical D library with implicit sRGB 
* and then adds colorspace defined by CSS.
*
* Copyright: Copyright Guillaume Piolat 2023.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/

module colors.colorspace;


// Is this supposed to supersede Gamut PixelType?

/// The Predefined Color Spaces. For now, no custom space.
enum Colorspace
{
    /// A 8-bit luminance sRGB value.
    l8,

    /// A 8-bit luminance sRGB value, with alpha.
    la8,

    /// A 8-bit tristimulus sRGB color.
    rgb8,

    /// A 8-bit tristimulus sRGB color, with alpha.
    /// This is the most common encoding, and is here to avoid needless conversion for this case.
    rgba8,

    
    // Below: CSS-compatible color spaces.

    /// A 32-bit float tristimulus sRGB color, with alpha. Called "srgb" in CSS.
    /// CSS functions such as rgb() return that.
    rgbaf32,

    /// A 32-bit float Hue Saturation Luminance space that is based-upon sRGB. "hsl" in CSS.
    hslaf32

/+
    /// The sRGB-linear predefined color space is the same as srgb except that the transfer 
    /// function is linear-light (there is no gamma-encoding).
    srgb_linear,

    display_p3,

    a98_rgb,

    prophoto_rgb,

    xyz,
    xyz_D50,
    xyz_D65,

    hsl,
    hwb,
    lch,
    oklch,
    lab,
    oklab
    +/
}



// All monomorphic color types defined here.
// Typically you would use `Color` instead of those directly.


/// A 8-bit luminance sRGB value.
align(1) struct L8
{
    align(1):
    ubyte l = 0;
}
static assert(L8.sizeof == 1);
unittest
{
    // Create such a color like this
    L8 midgrey = L8(128);
}


/// A 8-bit luminance sRGB value, with alpha.
align(1) struct LA8
{
align(1):
    ubyte l = 0;
    ubyte a = 0;
}
static assert(LA8.sizeof == 2);
unittest
{
    // Create such a color like this
    LA8 transparentWhite = LA8(255, 0);
}

/// A 8-bit tristimulus sRGB color.
/// See_also: `rgb8` convenience function to create one such color.
align(1) struct RGB8
{
align(1):
    ubyte r = 0, 
          g = 0, 
          b = 0;
}
unittest
{
    // Create such a color like this
    RGB8 yellow = RGB8(255, 255, 0);
}

/// A 8-bit tristimulus sRGB color, with alpha.
/// This is the most common encoding, and is here to avoid needless conversion for this case.
/// See_also: `rgba8` convenience function to create one such color.
align(1) struct RGBA8
{
align(1):
    ubyte r = 0, 
          g = 0, 
          b = 0,
          a = 0;
}
unittest
{
    assert(RGBA8.init == RGBA8(0, 0, 0, 0)); // transparent black by default
}

/// A 32-bit float tristimulus sRGB color, with alpha.
/// This is the most common encoding, and is here to avoid needless conversion for this case.
/// This is what most CSS functions resolve to, because of precision needs.
/// Warning: `r`, `g` and `b` have a range 0 to 1, unlike in CSS.
///          but `a` has a range 0 to 1. All can be `float.nan` ("none" in CSS).
/// See_also: `rgb` and `rgba` functions to create one such color.
struct RGBAf
{
    float r = 0, 
          g = 0, 
          b = 0, 
          a = 0;
}

/// A 32-bit float Hue Saturation Luminance space that is based-upon sRGB. "hsl" in CSS.
/// Warning: `h` is in a degrees modulo space (0 to 360)
///           `s`, `l` and `a` have a range 0 to 1.
///           All can be `float.nan` ("none" in CSS).
/// See_also: `hsl` and `hsla` functions to create one such color.
struct HSLAf
{
    float h = 0, 
          s = 0, 
          l = 0, 
          a = 0;
}