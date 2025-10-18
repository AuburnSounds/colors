module itu_h273;


/+

nothrow @nogc:

/// ColourPrimaries indicates the chromaticity coordinates 
/// of the source colour primaries as specified in Table 2
/// in terms of the CIE 1931 definition of x and y as
/// specified by ISO/CIE 11664-1.

enum ColourPrimaries : ubyte;

private struct PrimariesData
{
    float x_green, y_green;
    float x_blue, y_blue;
    float x_red, y_red;
    float x_white, y_white;
}

private PrimariesData getColourPrimaries(ColourPrimaries cp,
    out bool reserved,
    out bool unspecified)
{
    switch (cp)
    {
        case 0:
        case 3:
        case 13: .. case 21:
        case 23: .. case 255:

            reserved = true;
            return PrimariesData.init;

        case 2:
            unspecified = true;
            return PrimariesData.init;

        default:
             return PRIMARIES[cp-1];
    }

    

}

private static immutable PrimariesData[22] PRIMARIES = 
[
    PrimariesData(0.300, 0.600, 0.150, 0.060, 
                  0.640, 0.330, 0.3127, 0.3290), 
    PrimariesData.init,
    PrimariesData.init,
    PrimariesData(0.210, 0.710, 0.140, 0.080, 
                  0.670, 0.330, 0.3100, 0.3160),

    PrimariesData(0.290, 0.600, 0.150,  0.060, 
                  0.640, 0.330, 0.3127, 0.3290),
    PrimariesData(0.310, 0.595, 0.155,  0.070, 
                  0.630, 0.340, 0.3127, 0.3290), // 6
    PrimariesData(0.310, 0.595, 0.155,  0.070, 
                  0.630, 0.340, 0.3127, 0.3290), // 7
    PrimariesData(0.243, 0.692, 0.145,  0.049, 
                  0.681, 0.319, 0.310,  0.316), // Generic film
    PrimariesData(0.170, 0.797, 0.131,  0.046,  // 9
                  0.708, 0.292, 0.3127, 0.3290),

    // CIE 1931 XYZ, in YZX order
    PrimariesData(0.000, 1.000, 0.000,  0.000,  // SMPTE ST 428-1
                  1.000, 0.000, 0.3333333f, 0.333333f),
    PrimariesData(0.265, 0.690, 0.150,  0.060,
                  0.680, 0.320, 0.314f, 0.351f),
    PrimariesData(0.265, 0.690, 0.150,  0.060,
                  0.680, 0.320, 0.3127f, 0.3290f), // 12
    PrimariesData.init, // 13
    PrimariesData.init, // 14
    PrimariesData.init, // 15
    PrimariesData.init, // 16
    PrimariesData.init, // 17
    PrimariesData.init, // 18
    PrimariesData.init, // 19
    PrimariesData.init, // 20
    PrimariesData.init, // 21
    PrimariesData(0.295, 0.605, 0.155,  0.077,
                  0.680, 0.340, 0.3127f, 0.3290f)
];

alias TransferCharacteristics = ubyte;


double transferColor(double Lc, 
                     TransferCharacteristics car,
                     out bool reserved,
                     out bool unspecified)
{
    switch(car)
    {
        case 0:
        case 3:
        case 19: .. case 255:
            reserved = true; 
            break;



        case 1: 
        case 6: 
        case 14: 
        case 15: 
        {
            double alpha = 1.099296826809442;
            double beta = 0.018053968510807;
            if (Lc < beta) return Lc * 4.5;          
        }

        case 8:


    }


}
+/