/**
    Monomorphic color type, to represent any tristimulus + alpha.

    Copyright: Copyright Guillaume Piolat 2023-2024.
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, BSL-1.0)
*/
module colors.types;

//import std.math;
import colors.conversions;
import colors.colorspace;
import colors.parser;


pure nothrow @nogc @safe:


/**
    The Color type is a tagged union that can hold one color in a
    CSS-defined colorspace. This correspond to both "specified",
    "computed", and "used" colors in CSS specification.
    In typical use, you'll want to map to sRGB 32-bit RGBA quadruplet,
    and the function for this is called: `toRGBA8()`.
    Reference: https://www.w3.org/TR/css-color-4/
*/
struct Color
{
pure nothrow @nogc @safe:

    // Note: accessing these representation is dangerous, only one of
    // them is meaningful according to `colorspace`.
    union
    {
        // Efficient representation go there:
        RGBA8 _RGBA8;
        RGBA16 _RGBA16;

        // CSS spec recommends:
        // "(16bit, half-float, or float per component is recommended
        // for internal storage).
        // Values must be rounded towards +∞, not truncated."
        // CSS-compatible types below, with more precision.
        // Note that the CSS types can contain NaN, unlike the
        // efficient representations, and it's meaningful.

        RGBAf _RGBAf;
        HSLAf _HSLAf;
    }

    /**
        Build from CSS color string.
    */
    this(const(char)[] cssColor)
    {
        this = color(cssColor);
    }

    /**
        Build from a 8-bit sRGB quadruplet.
    */
    this(RGBA8 c)
    {
        this._RGBA8 = c;
        this._colorspace = Colorspace.rgba8;
    }

    /**
        Build from a 16-bit sRGB quadruplet.
    */
    this(RGBA16 c)
    {
        this._RGBA16 = c;
        this._colorspace = Colorspace.rgba16;
    }


    /**
        Build from a 32-bit float sRGB quadruplet.
    */
    this(RGBAf c)
    {
        this._RGBAf = c;
        this._colorspace = Colorspace.rgbaf32;
    }

    /**
        Get colorspace tag. This is the tag of this tagged union.
    */
    Colorspace colorspace() const
    {
        return _colorspace;
    }

    /**
        Unsafe cast of colorspace. Normally you never need this.
    */
    void assumeColorspace(Colorspace colorspace) @system
    {
        _colorspace = colorspace;
    }

    /**
        Returns: A 8-bit tristimulus sRGB color, with alpha.
    */
    RGBA8 toRGBA8() const
    {
        Color c = this.toColorSpace(Colorspace.rgba8);
        return c._RGBA8;
    }

    /**
        Returns: A 16-bit tristimulus sRGB color, with alpha.
    */
    RGBA16 toRGBA16() const
    {
        Color c = this.toColorSpace(Colorspace.rgba16);
        return c._RGBA16;
    }

    /**
        A 32-bit float normalized tristimulus sRGB color, with alpha.
    */
    RGBAf toRGBAf() const
    {
        Color c = this.toColorSpace(Colorspace.rgbaf32);
        return c._RGBAf;
    }

private:
    /**
        Colorspace in the type. Which means `Color` is not meant for
        storage, but for intermediate computation and user experience.
    */
    Colorspace _colorspace;
}
unittest
{
    Color c = Color("cyan");
}


/**
    The `rgb` function is the same as in CSS color specifications.

    Expected values ranges from 0 to 255.

    Instead of being either numbers or percentages, all values here
    are assumed to be numbers from 0 to 255. However, internally the
    color will be stored with higher accuracy, as per CSS spec.

    Params:
      red   = Red value in 0 to 255.0f.
      green = Green value in 0 to 255.0f.
      blue  = Blue value in 0 to 255.0f.
      alpha = Alpha value in 0 to 1.0f (opacity).
*/
Color rgb(float red, float green, float blue, float alpha = 1.0f)
{
    clamp_0_255(red);
    clamp_0_255(green);
    clamp_0_255(blue);
    clamp_0_1(alpha);
    Color c;
    c._RGBAf.r = red / 255.0f;
    c._RGBAf.g = green / 255.0f;
    c._RGBAf.b = blue / 255.0f;
    c._RGBAf.a = alpha;
    c._colorspace = Colorspace.rgbaf32;
    return c;
}


/**
    In CSS, the `rgba` function is simply in alias of `rgb`. You can
    specify an alpha to `rgb`, or omit it with `rgba`.
*/
alias rgba = rgb;


/**
    The `hsl` function is the same as in CSS color specifications.

    Expected values ranges from 0 to 255.

    Params:
      hueDegrees = Hue value (0 = red, 60 = yellow, 240 = blue).
                 = Can wrap around.
      sat        = Saturation value in 0 to 1.0f.
      light      = Light value in 0 to 1.0f.
      alpha      = Alpha value in 0 to 1.0f (opacity).
*/
Color hsl(float hueDegrees,
          float sat,
          float light,
          float alpha = 1.0f)
{
    // TODO: should clamp or fmod hueDegrees here?
    clamp_0_1(sat);
    clamp_0_1(light);
    clamp_0_1(alpha);
    Color c;
    c._HSLAf.h = hueDegrees,
    c._HSLAf.s = sat;
    c._HSLAf.l = light;
    c._HSLAf.a = alpha;
    c._colorspace = Colorspace.hslaf32;
    return c;
}


/**
    In CSS, the `hsla` function is simply in alias of `rgb`. You can
    specify an alpha to `rgb`, or omit it with `rgba`.
*/
alias hsla = hsl;


/**
    Convert a `Color` in-place to another colorspace.
*/
Color toColorSpace(const(Color) color, Colorspace target)
{
    // CSS mandates that we preserve at least 16-bit of precision.

    Colorspace from = color.colorspace;

    if (target == Colorspace.unknown)
    {
        // Not supposed to happen, every Color are convertible to any
        // other space (though the semantics could change).
        assert(false);
    }

    if (from == target)
        return color; // already there

    Colorspace inter = getIntermediateColorspace(from, target);

    if (from == inter)
    {
        return convertFromIntermediate(color, target);
    }
    else if (target == inter)
    {
        return convertToIntermediate(color, target);
    }
    else
    {
        Color c = convertToIntermediate(color, inter);
        return convertFromIntermediate(c, target);
    }
}

