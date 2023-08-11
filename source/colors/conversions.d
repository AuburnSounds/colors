/**
* Conversions, intended for internal library usage.
*
* Copyright: Copyright Guillaume Piolat 2023.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module colors.conversions;


import colors.types;

pure nothrow @nogc @safe:

/// Converting HSL to sRGB.
/// Params: 
///    hue Hue as degrees 0..360.
///    sat Saturation as 0..1.0f.
///    light Lightness as 0..1.0f.
/// Reference: https://www.w3.org/TR/css-color-4/#hsl-to-rgb
float[3] hslToRgb(float hue, float sat, float light) 
{
    assert(hue >= -360 && hue <= 720.0f);
    assert(sat >= 0.0f && sat <= 1.0f);
    assert(light >= 0.0f && light <= 1.0f);

    // Convert hue to integer here.
    // Round to single degree.
    // FUTURE: round to 16th of degrees to support very fine hues.
    int ihue = cast(int)(hue * 16 + 360 + 0.5f);
    ihue = ihue % 360;
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


// Reference: https://www.w3.org/TR/css-color-4/#hsl-to-rgb