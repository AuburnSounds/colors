/**
* Conversions, intended for internal library usage.
*
* Copyright: Copyright Guillaume Piolat 2023.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module colors.conversions;


import colors.types;
import colors.colorspace;

// This is for internal use.

pure nothrow @nogc @safe:

/// Converting HSL to sRGB.
/// Params: 
///    hue Hue as degrees 0..360.
///    sat Saturation as 0..1.0f.
///    light Lightness as 0..1.0f.
/// Reference: https://www.w3.org/TR/css-color-4/#hsl-to-rgb
float[3] hslToRgb(float hue, float sat, float light) 
{
    assert(hue >= -360 && hue <= 720.0f); // blerg, where to lift that limitation?
    assert(sat >= 0.0f && sat <= 1.0f);
    assert(light >= 0.0f && light <= 1.0f);

    //import core.stdc.stdio;
    //debug printf("hslToRgb(%f, %f, %f)\n", hue, sat, light);
    
    // Convert hue to integer here.
    // Round to single degree.
    // FUTURE: round to 16th of degrees to support very fine hues.
    int ihue = cast(int)(hue + 360 + 0.5f);
    //debug printf("ihue = %d\n", ihue);
    ihue = ihue % 360; // TODO: that doesn't sound very precise?
    //debug printf("ihue = %d\n", ihue);
    if (ihue < 0) ihue += 360;
    assert(ihue >= 0 && ihue < 360);

    float ll = light;
    if (ll > 1 - light)
        ll = 1 - light;

    float amp = sat * ll;

    float f(int n) pure nothrow @nogc @safe
    {
        float k = (n + ihue / 30) % 12;
        float D = k - 3;
        if (D > 9-k) D = 9-k;
        if (D > 1) D = 1;
        if (D < -1) D = -1;
        return light - amp * D;
    }
    return [f(0), f(8), f(4)];
}


// Reference: https://www.w3.org/TR/css-color-4/#rgb-to-hsl
// Note: this can return NaN as hue if there is no hue.
float[3] rgbToHsl (float red, float green, float blue) 
{
    // TODO: how to deal with NaN here? clamp?
    float max = (red > green) ? red : green;
    max = (max > blue) ? max : blue;
    float min = (red < green) ? red : green;
    min = (min < blue) ? min : blue;

    float light = (min + max) * 0.5f;
    float sat = 0;
    float hue = float.nan;
    float d = max - min;

    if (d != 0) 
    {
        if (light <= 0 || light >= 1)
            sat = 0;
        else
        {
            float one_minus_light = 1.0f - light;
            float mm = (light < one_minus_light) ? light : one_minus_light;
            sat = d / mm;
        }
        if (max == red)
        {
            hue = (green - blue) / d + (green < blue ? 6 : 0); 
        }
        else if (max == green)
        {
            hue = (blue - red) / d + 2;
        }
        else
        {
            hue = (red - green) / d + 4;
        }
        hue = hue * 60;
    }

    float[3] res = [hue, sat, light];
    return res;
}


Colorspace getIntermediateColorspace(Colorspace source, Colorspace target) pure
{
    with(Colorspace)
    {
        if (source <= rgba8 && target <= rgba8)
            return rgba8;

        return rgbaf32;
    }
}

Color convertToIntermediate(Color c, Colorspace target) @trusted
{
    Colorspace source = c.colorspace;
    Color r = void;
    r.assumeColorspace(target);

    switch(target) with (Colorspace)
    {
    case rgba8:
        switch(source)
        {
            case l8:
                r._RGBA8.r = c._L8.l;
                r._RGBA8.g = c._L8.l;
                r._RGBA8.b = c._L8.l;
                r._RGBA8.a = 255;
                break;

            case la8:
                r._RGBA8.r = c._LA8.l;
                r._RGBA8.g = c._LA8.l;
                r._RGBA8.b = c._LA8.l;
                r._RGBA8.a = c._LA8.a;
                break;

            case rgb8:
                r._RGBA8.r = c._RGB8.r;
                r._RGBA8.g = c._RGB8.g;
                r._RGBA8.b = c._RGB8.b;
                r._RGBA8.a = 255;
                break;

            case rgba8:
                r._RGBA8 = c._RGBA8;
                break;

            default:
                break;

        }
        break;

    case rgbaf32:
        switch(source)
        {
            case l8:
                r._RGBAf.r = c._L8.l / 255.0f;
                r._RGBAf.g = c._L8.l / 255.0f;
                r._RGBAf.b = c._L8.l / 255.0f;
                r._RGBAf.a = 1.0f;
                break;

            case la8:
                r._RGBAf.r = c._LA8.l / 255.0f;
                r._RGBAf.g = c._LA8.l / 255.0f;
                r._RGBAf.b = c._LA8.l / 255.0f;
                r._RGBAf.a = c._LA8.a / 255.0f;
                break;

            case rgb8:
                r._RGBAf.r = c._RGB8.r / 255.0f;
                r._RGBAf.g = c._RGB8.g / 255.0f;
                r._RGBAf.b = c._RGB8.b / 255.0f;
                r._RGBAf.a = 1.0f;
                break;

            case rgba8:
                r._RGBAf.r = c._RGBA8.r / 255.0f;
                r._RGBAf.g = c._RGBA8.g / 255.0f;
                r._RGBAf.b = c._RGBA8.b / 255.0f;
                r._RGBAf.a = c._RGBA8.a / 255.0f;
                break;

            case rgbaf32:
                r._RGBAf = c._RGBAf;
                break;

            case hslaf32:
                // TODO: read in CSS what to do with large hue values, or NaN values, here.
                float[3] rgb = hslToRgb(c._HSLAf.h, c._HSLAf.s, c._HSLAf.l);                
                r._RGBAf.r = rgb[0];
                r._RGBAf.g = rgb[1];
                r._RGBAf.b = rgb[2];
                r._RGBAf.a = c._HSLAf.a;
                break;

            default:
                assert(false); // Not implemented or impossible
        }
        break;

        default:
            assert(false); // This intermediate doesn't exist.
    }
    return r;
}

// Internal use, convert from the intermediate format to the target format.
// This reduces bitdepth.
Color convertFromIntermediate(Color c, Colorspace target) @trusted
{
    Colorspace source = c.colorspace;
    Color r = void;
    r.assumeColorspace(target);

    switch(source) with (Colorspace)
    {
        case rgba8:
            switch(target)
            {
                // TODO: not sure where to clamp
                case l8:
                    r._L8.l = cast(ubyte)( (c._RGBA8.r + c._RGBA8.g + c._RGBA8.b + 2) / 3 );
                    break;

                case la8:
                    r._LA8.l = cast(ubyte)( (c._RGBA8.r + c._RGBA8.g + c._RGBA8.b + 2) / 3 );
                    r._LA8.a = c._RGBA8.a;
                    break;

                case rgb8:
                    r._RGB8.r = c._RGBA8.r;
                    r._RGB8.g = c._RGBA8.g;
                    r._RGB8.b = c._RGBA8.b;
                    break;

                case rgba8:
                    r._RGBA8 = c._RGBA8;
                    break;

                default:
                    break;
            }
            break;

        case rgbaf32:

            // TODO: clamp and remove NaN?
            switch(target)
            {
                case l8:
                    r._L8.l = cast(ubyte)(0.5f + 255.0f * (c._RGBAf.r + c._RGBAf.g + c._RGBAf.b) / 3.0f);
                    break;

                case la8:
                    r._LA8.l = cast(ubyte)(0.5f + 255.0f * (c._RGBAf.r + c._RGBAf.g + c._RGBAf.b) / 3.0f);
                    r._LA8.a = cast(ubyte)(0.5f + 255.0f * c._RGBAf.a);
                    break;

                case rgb8:
                    r._RGB8.r = cast(ubyte)(0.5f + 255.0f * c._RGBAf.r);
                    r._RGB8.g = cast(ubyte)(0.5f + 255.0f * c._RGBAf.g);
                    r._RGB8.b = cast(ubyte)(0.5f + 255.0f * c._RGBAf.b);
                    break;

                case rgba8:
                    r._RGBA8.r = cast(ubyte)(0.5f + 255.0f * c._RGBAf.r);
                    r._RGBA8.g = cast(ubyte)(0.5f + 255.0f * c._RGBAf.g);
                    r._RGBA8.b = cast(ubyte)(0.5f + 255.0f * c._RGBAf.b);
                    r._RGBA8.a = cast(ubyte)(0.5f + 255.0f * c._RGBAf.a);
                    break;

                case rgbaf32:
                    r._RGBAf = c._RGBAf;
                    break;

                case hslaf32:

                    // TODO
                    assert(false);
                    //break;

                default:
                    assert(false); // Not implemented or impossible
            }
            break;

        default:
            assert(false); // This intermediate doesn't exist.
    }
    return r;
}

void clamp_0_1(ref float x) pure
{
    if (x < 0) x = 0;
    if (x > 1) x = 1;
}

void clamp_0_255(ref float x) pure
{
    if (x < 0) x = 0;
    if (x > 255) x = 255;
}