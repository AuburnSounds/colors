/**
* Monomorphic color type, intended to represent any tristimulus color.
*
* Copyright: Copyright Guillaume Piolat 2023.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module colors.types;

nothrow @nogc @safe:

import std.math;

import colors.conversions;


/// The CSS Predefined Color Spaces.
enum Colorspace
{
    /// The sRGB predefined color space defined below is the same as is used for legacy sRGB 
    /// colors, such as rgb().
    srgb,

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
}


/// The Color type holds both a (runtime) color type and value.
/// This correspond to both "specified", "computed", and "used" colors in CSS.
/// In typical usage, you will want to map to sRGB 32-bit RGBA quadruplet.
/// Basically a tagged union.
/// Reference: https://www.w3.org/TR/css-color-4/
struct Color
{
public:
nothrow:
@nogc:
@safe:
    /// CSS spec recommends:
    /// "(16bit, half-float, or float per component is recommended for internal storage). 
    /// Values must be rounded towards +∞, not truncated."
    union
    {
        struct
        {
            float r, g, b;
        }

        struct
        {
            float h, s, l;
        }
    }

    // Opacity value, represented from 0.0f (transparent) to 1.0f (opaque).
    float a; 

    /// Converts the color to a quadruplet of R, G, B, A bytes.
    ubyte[4] toSRGB()
    {
        final switch(colorSpace) with (Colorspace)
        {
            case srgb: assert(0);
            case srgb_linear: assert(0);
            case display_p3: assert(0);
            case a98_rgb: assert(0);
            case prophoto_rgb: assert(0);
            case xyz: assert(0);
            case xyz_D50: assert(0);
            case xyz_D65: assert(0);
            case hsl: assert(0);
            case hwb: assert(0);
            case lch: assert(0);
            case oklch: assert(0);
            case lab: assert(0);
            case oklab: assert(0);
        }

    }

private:
    Colorspace colorSpace;
}


/// The `rgb` function is the same as in CSS color specifications.
///
/// Expected values ranges from 0 to 255.
///
/// Instead of being either numbers or percentages, all values here 
/// are assumed to be numbers from 0 to 255. However, internally the 
/// color will be stored with higher accuracy, as per CSS spec.
///
/// Params:
///   red    Red value in 0 to 255.0f.
///   green  Green value in 0 to 255.0f.
///   blue   Blue value in 0 to 255.0f.
///   alpha  Alpha value in 0 to 1.0f (opacity).
Color rgb(float red, float green, float blue, float alpha = 1.0f)
{
    Color c;
    c.r = red;
    c.g = green;
    c.b = blue;
    c.a = alpha;
    c.colorSpace = Colorspace.srgb;
    return c;
}

/// In CSS, `rgba` is simply in alias of `rgb`. You can specify an alpha to `rgb`, or omit it with 
/// `rgba`.
alias rgba = rgb;


/// The `hsl` function is the same as in CSS color specifications.
///
/// Expected values ranges from 0 to 255.
///
/// Params:
///   hue   Hue value in degrees (0 = red, 60 = yellow, 240 = blue). Can wrap around.
///   sat   Saturation value in 0 to 1.0f.
///   light Light value in 0 to 1.0f.
///   alpha Alpha value in 0 to 1.0f (opacity).
Color hsl(float hueDegrees, float sat, float light, float alpha = 1.0f)
{
    Color c;
    c.h = hueDegrees,
    c.s = sat;
    c.l = light;
    c.a = alpha;
    c.colorSpace = Colorspace.hsl; // Return a color still represented as HSL.
    return c;
}

/// In CSS, `hsla` is simply in alias of `hsl`. You can specify an alpha to `hsla`, or omit it with 
/// `hsla`.
alias hsla = hsl;

/+
    // Convert to turns
    float hueTurns = hueDegrees / 360.0f;
    hueTurns -= floor(hueTurns); // take remainder
    float hue = 6.0 * hueTurns;

    // Saturation and lightness are clipped.
    if (sat < 0) sat = 0;
    if (sat > 1) sat = 1;
    if (light < 0) light = 0;
    if (light > 1) light = 1;

    // For now, we store it in sRGB space.
    Color c;
    float[3] rgb = convertHSLtoRGB(hue, sat, light);

    red   = clamp0to255( cast(int)(0.5 + 255.0 * rgb[0]) );
    green = clamp0to255( cast(int)(0.5 + 255.0 * rgb[1]) );
    blue  = clamp0to255( cast(int)(0.5 + 255.0 * rgb[2]) );
    return c;
}


+/

