module colors.conversions;


import colors.types;



// Reference: https://www.w3.org/TR/css-color-4/#hsl-to-rgb
// this algorithm assumes that the hue has been normalized to a number in the half-open range [0, 6), 
// and the saturation and lightness have been normalized to the range [0, 1]. 
double[3] convertHSLtoRGB(double hue, double sat, double light) pure nothrow @nogc @safe
{
    double t2;
    if( light <= .5 ) 
        t2 = light * (sat + 1);
    else 
        t2 = light + sat - (light * sat);
    double t1 = light * 2 - t2;
    double r = convertHueToRGB(t1, t2, hue + 2);
    double g = convertHueToRGB(t1, t2, hue);
    double b = convertHueToRGB(t1, t2, hue - 2);
    return [r, g, b];
}

double convertHueToRGB(double t1, double t2, double hue) pure nothrow @nogc @safe
{
    if (hue < 0) 
        hue = hue + 6;
    if (hue >= 6) 
        hue = hue - 6;
    if (hue < 1) 
        return (t2 - t1) * hue + t1;
    else if(hue < 3) 
        return t2;
    else if(hue < 4) 
        return (t2 - t1) * (4 - hue) + t1;
    else 
        return t1;
}