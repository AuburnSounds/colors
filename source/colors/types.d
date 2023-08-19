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
import colors.colorspace;

nothrow @nogc @safe:

/// The Color type is a tagged union that can hold any predefined colorspace.
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
    
    // Note: accessing these representation is dangerous, only one of them is meaningful
    // according to `colorspace`.
    union
    {
        // Efficient representation go there:
        L8    _L8;
        LA8   _LA8;
        RGB8  _RGB8;
        RGBA8 _RGBA8;

        // CSS spec recommends:
        // "(16bit, half-float, or float per component is recommended for internal storage). 
        // Values must be rounded towards +∞, not truncated."
        // CSS-compatible types below, with more precision.
        // Note that the CSS types can contain NaN, unlike the efficient representations.

        RGBAf _RGBAf;
        HSLAf _HSLAf;
    }

    /// Get colorspace tag. This decices which member is meaningful.
    Colorspace colorspace()
    {
        return _colorspace;
    }

    /// Unsafe cast of colorspace. Normally you never need this.
    void assumeColorspace(Colorspace colorspace) @system
    {
        _colorspace = colorspace;
    }

    /// Tag the colorspace in the type. Which means `Color` is not meant for storage, but for 
    /// intermediate computation.
    Colorspace _colorspace; 
}

pragma(msg, Color.sizeof);

    



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
    c._RGBAf.r = red / 255.0f;
    c._RGBAf.g = green / 255.0f;
    c._RGBAf.b = blue / 255.0f;
    c._RGBAf.a = alpha;
    c._colorspace = Colorspace.rgbaf32;
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
    c._HSLAf.h = hueDegrees,
    c._HSLAf.s = sat;
    c._HSLAf.l = light;
    c._HSLAf.a = alpha;
    c._colorspace = Colorspace.hslaf32; // Return a color still represented as HSL.
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


/// Convert a `Color` to another colorspace.
/// Converts the color in-place to another colorspace, preserving at least 16-bit of precision.
Color convertColorToColorspace(Color color, Colorspace target)
{
    Colorspace from = color.colorspace;
    if (from == target)
        return color; // already there

    Colorspace inter = getIntermediateColorspace(from, target);

    if (inter == from) // already in right space
    {
        // Conversion here
        assert(false);
    }
    else
    {
        // Else recurse (must make progress).
        Color tmp = convertColorToColorspace(color, inter);
        return convertColorToColorspace(tmp, target);
    }
}

Colorspace getIntermediateColorspace(Colorspace source, Colorspace target)
{
    return Colorspace.rgba8;
}