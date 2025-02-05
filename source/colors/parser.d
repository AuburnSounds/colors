/**
    Implement CSS color parsing, like specified.
    This uses the functions defined elsewhere in `colors`.

    Copyright: Copyright Guillaume Piolat 2020-2024.
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, BSL-1.0)
*/
module colors.parser;

import std.math: PI, floor;

import core.stdc.string: strlen;

import colors.types;
import colors.colorspace;
import colors.conversions;

/** 
    Parses a CSS color string, and gives back a `Color`.
    If parsing fails, return transparent black.

    See_also: `parseCSSColor`.
*/
Color color(const(char)[] cssColorString) pure nothrow @nogc @safe
{
    Color c;
    string err;
    if (parseCSSColor(cssColorString, c, err))
        return c;
    else
        return c.init;
}
unittest
{
    Color c;
    assert(color("invalidname") == Color.init);
    assert(color("red").toRGBA8() == RGBA8(255, 0, 0, 255));
}


/**
    Parses a CSS color string, and gives back a `Color`.
   
    Params:
        cssColorString = A CSS string describing a color.
        outColor       = Output color.
        error          = Error message. `null` on success.
   
    Returns:
        A specified Color, that keeps the intent of the user. 
        This is not necessarily usable right away, and will typically 
        need sRGB conversion.
        In other words, colors stay in their colorspace of definition.
   
    See_also: https://www.w3.org/TR/css-color-4/
   
   
    Example:
    ---
    import colors;
    
    // all HTML named colors
    parseCSSColor("black", color, error);
    
    // hex colors including alpha versions
    parseCSSColor("#fe85dc", color, error);

    // alpha                    
    parseCSSColor("rgba(64, 255, 128, 0.24)", color, error);   

    // percentage, floating-point
    parseCSSColor("rgb(9e-1, 50%, 128)", color, error);

    // hsv colors
    parseCSSColor("hsl(120deg, 25%, 75%)", color, error);

    // gray colors
    parseCSSColor("gray(0.5)", color, error);

    // strips whitespace
    parseCSSColor(" rgb ( 245 , 112 , 74 )  ", color, error);  
    ---
   
*/
bool parseCSSColor(const(char)[] cssColorString, 
                   out Color outColor, 
                   out string error) pure nothrow @nogc @safe
{

    error = null; // indicate success
    const(char)[] s = cssColorString;   
    int index = 0;    

    char peek() nothrow @nogc @safe
    {
        if (index >= cssColorString.length)
            return '\0';
        else
            return s[index];
    }

    void next() nothrow @nogc @safe
    {
        index++;
    }

    bool parseChar(char ch) nothrow @nogc @safe
    {
        if (peek() == ch)
        {
            next;
            return true;
        }
        return false;
    }

    bool expectChar(char ch) nothrow @nogc @safe
    {
        if (!parseChar(ch))
            return false;
        return true;
    }

    bool parseString(string s) nothrow @nogc @safe
    {
        int save = index;

        for (int i = 0; i < s.length; ++i)
        {
            if (!parseChar(s[i]))
            {
                index = save;
                return false;
            }
        }
        return true;
    }

    bool isWhite(char ch) nothrow @nogc @safe
    {
        return ch == ' '  || ch == '\n' || ch == '\r' 
            || ch == '\t' || ch == '\r';
    }

    bool isDigit(char ch) nothrow @nogc @safe
    {
        return ch >= '0' && ch <= '9';
    }

    bool expectDigit(out char digit) nothrow @nogc @safe
    {
        char ch = peek();
        if (isDigit(ch))
        {            
            next;
            digit = ch;
            return true;
        }
        else
            return false;
    }

    bool parseHexDigit(out int digit)
        nothrow @nogc @safe
    {
        char ch = peek();
        if (isDigit(ch))
        {
            next;
            digit = ch - '0';
            return true;
        }
        else if (ch >= 'a' && ch <= 'f')
        {
            next;
            digit = 10 + (ch - 'a');
            return true;
        }
        else if (ch >= 'A' && ch <= 'F')
        {
            next;
            digit = 10 + (ch - 'A');
            return true;
        }
        else
            return false;
    }

    void skipWhiteSpace() nothrow @nogc @safe
    {       
        while (isWhite(peek()))
            next;
    }

    bool expectOptionalPunct(char ch) nothrow @nogc @safe
    {
        skipWhiteSpace();
        bool seen = false;
        char pch = peek();
        if (pch == ch)
        {            
            seen = true;
            next;
        }
        skipWhiteSpace();
        return seen;
    }

    bool expectPunct(char ch) nothrow @nogc @safe
    {
        skipWhiteSpace();
        if (!expectChar(ch))
            return false;
        skipWhiteSpace();
        return true;
    }

    ubyte clamp0to255(int a) nothrow @nogc @safe
    {
        if (a < 0) return 0;
        if (a > 255) return 255;
        return cast(ubyte)a;
    }

    // See: https://www.w3.org/TR/css-syntax/#consume-a-number
    bool parseNumber(double* number, out string error) @trusted
        nothrow @nogc
    {
        char[32] repr;
        int repr_len = 0;

        if (parseChar('+'))
        {}
        else if (parseChar('-'))
        {
            if (repr_len >= 31) return false;
            repr[repr_len++] = '-';
        }
        while(isDigit(peek()))
        {
            if (repr_len >= 31) return false;
            repr[repr_len++] = peek();
            next;
        }
        if (peek() == '.')
        {
            if (repr_len >= 31) return false;
            repr[repr_len++] = '.';
            next;
            char digit;
            bool parsedDigit = expectDigit(digit);
            if (!parsedDigit)
                return false;

            if (repr_len >= 31) return false;
            repr[repr_len++] = digit;

            while(isDigit(peek()))
            {
                if (repr_len >= 31) return false;
                repr[repr_len++] = peek();
                next;
            }
        }
        if (peek() == 'e' || peek() == 'E')
        {
            if (repr_len >= 31) return false;
            repr[repr_len++] = 'e';
            next;
            if (parseChar('+'))
            {}
            else if (parseChar('-'))
            {
                if (repr_len >= 31) return false;
                repr[repr_len++] = '-';
            }
            while(isDigit(peek()))
            {
                if (repr_len >= 31) return false;
                repr[repr_len++] = peek();
                next;
            }
        }

        // force a '\0' to be there, making sscanf bounded
        repr[repr_len++] = '\0'; 
        assert(repr_len <= 32);


        bool err;
        double scanned = convertStringToDouble(repr.ptr, false, &err);
        if (!err)
        {
            *number = scanned;
            return true;
        }
        else
        {
            error = "Couln't parse number";
            return false;
        }
    }

    bool parseColorValue(out float result, out string error) @trusted
        nothrow @nogc
    {
        double number;
        if (!parseNumber(&number, error))
        {
            return false;
        }
        bool isPercentage = parseChar('%');
        if (isPercentage)
            number *= (255.0 / 100.0);

        // No clamping!
        // "Values outside these ranges are not invalid, but are 
        // clamped to the ranges defined here at computed-value time."
        result = number;
        return true; 
    }

    bool parseOpacity(out float result, out string error) @trusted
        nothrow @nogc
    {
        double number;
        if (!parseNumber(&number, error))
        {
            return false;
        }

        // "Values outside the range [0,1] are not invalid, but are 
        // clamped to that range when computed."
        bool isPercentage = parseChar('%');
        if (isPercentage)
            number *= 0.01;

        result = number;
        return true;
    }

    bool parsePercentage(out double result, out string error) @trusted
        nothrow @nogc
    {
        double number;
        if (!parseNumber(&number, error))
            return false;
        if (!expectChar('%'))
        {
            error = "Expected % in color string";
            return false;
        }
        result = number * 0.01;
        return true;
    }

    bool parseHueInDegrees(out double result, 
                           out string error) @trusted
        nothrow @nogc
    {
        double num;
        if (!parseNumber(&num, error))
            return false;

        if (parseString("deg"))
        {
            result = num;
            return true;
        }
        else if (parseString("rad"))
        {
            result = num * 360.0 / (2 * PI);
            return true;
        }
        else if (parseString("turn"))
        {
            result = num * 360.0;
            return true;
        }
        else if (parseString("grad"))
        {
            result = num * 360.0 / 400.0;
            return true;
        }
        else
        {
            // assume degrees
            result = num;
            return true;
        }
    }

    skipWhiteSpace();

    //ubyte red, green, blue, alpha = 255;

    if (parseChar('#'))
    {
       int red = 255, 
           green = 255,
           blue = 255,
           alpha = 255;

       int[8] digits;
       int numDigits = 0;
       for (int i = 0; i < 8; ++i)
       {
          if (parseHexDigit(digits[i]))
              numDigits++;
          else
            break;
       }
       switch(numDigits)
       {
       case 4:
           alpha  = cast(ubyte)( (digits[3] << 4) | digits[3]);
           goto case 3;
       case 3:
           red   = cast(ubyte)( (digits[0] << 4) | digits[0]);
           green = cast(ubyte)( (digits[1] << 4) | digits[1]);
           blue  = cast(ubyte)( (digits[2] << 4) | digits[2]);
           break;
       case 8:
           alpha  = cast(ubyte)( (digits[6] << 4) | digits[7]);
           goto case 6;
       case 6:
           red   = cast(ubyte)( (digits[0] << 4) | digits[1]);
           green = cast(ubyte)( (digits[2] << 4) | digits[3]);
           blue  = cast(ubyte)( (digits[4] << 4) | digits[5]);
           break;
       default:
           error = "Expected 3, 4, 6, or 8 digits in hex literal";
           return false;
       }
       outColor = rgba(red, green, blue, alpha / 255.0f);
    }
    else if (parseString("gray"))
    {
        float red = 255, 
              green = 255,
              blue = 255;
        float alpha = 1.0f;
        
        skipWhiteSpace();
        if (!parseChar('('))
        {
            // This is named color "gray"
            red = green = blue = 128;
        }
        else
        {
            skipWhiteSpace();
            float v;
            if (!parseColorValue(v, error))
                return false;
            red = green = blue = v;
            skipWhiteSpace();
            if (parseChar(','))
            {
                // there is an alpha value
                skipWhiteSpace();
                if (!parseOpacity(alpha, error))
                    return false;
            }
            if (!expectPunct(')'))
            {
                error = "Expected ) in color string";
                return false;
            }
        }
        outColor = rgba(red, green, blue, alpha);
    }
    else if (parseString("rgb"))
    {
        float red = 255, 
              green = 255,
              blue = 255;
        float alpha = 1.0f;
        bool hasAlpha = parseChar('a');
        if (!expectPunct('('))
        {
            error = "Expected ( in color string";
            return false;
        }
        int components = 0;
        if (!parseColorValue(red, error))
            return false;
        components += 1;
        bool parsedComma0 = expectOptionalPunct(',');
        if (!parseColorValue(green, error))
            return false;
        components += 1;
        bool parsedComma1 = expectOptionalPunct(',');
        if (!parseColorValue(blue, error))
            return false;
        components += 1;
        if (hasAlpha)
        {
            if (!expectPunct(','))
            {
                error = "Expected , in color string";
                return false;
            }
            if (!parseOpacity(alpha, error))
                return false;
            components += 1;
        }
        if (components <= 2)
        {
            error = "Not enough components";
            return false;
        }
        // lack of closing paren is valid
        bool hasClosingParen = expectOptionalPunct(')');
        outColor = rgba(red, green, blue, alpha);
    }
    else if (parseString("hsl"))
    {
        bool hasAlpha = parseChar('a');
        expectPunct('(');
        float alpha = 1.0f;
        double hueDegrees;
        if (!parseHueInDegrees(hueDegrees, error))
            return false;
        // Convert to turns
        if (!expectPunct(','))
        {
            error = "Expected , in color string";
            return false;
        }
        double sat;
        if (!parsePercentage(sat, error))
            return false;
        if (!expectPunct(','))
        {
            error = "Expected , in color string";
            return false;
        }
        double light;
        if (!parsePercentage(light, error))
            return false;
        if (hasAlpha)
        {
            if (!expectPunct(','))
            {
                error = "Expected , in color string";
                return false;
            }
            if (!parseOpacity(alpha, error))
                return false;
        }
        expectPunct(')');
        outColor = hsla(hueDegrees, sat, light, alpha);
    }
    else
    {
        // Initiate a binary search inside the sorted named color 
        // array.

        // Current search range
        // Will only reduce because the color names are sorted.
        int L = 0;
        int R = cast(int)(namedColors.length); 
        int charPos = 0;

        matchloop:
        while (true)
        {
            // Expect 
            char ch = peek();
            if (ch >= 'A' && ch <= 'Z')
                ch += ('a' - 'A');
            if (ch < 'a' || ch > 'z') // not alpha?
            {
                // Examine all alive cases. Select the one which have 
                // matched entirely.               
                foreach(candidate; L..R)
                {
                    // found it, return as there are no duplicates
                    if (namedColors[candidate].length == charPos)
                    {
                        // If we have matched all the alpha of the 
                        // only remaining candidate, we have found a 
                        // named color
                        uint uintColor = namedColorValues[candidate];
                        int r = (uintColor >> 24) & 0xff;
                        int g = (uintColor >> 16) & 0xff;
                        int b = (uintColor >>  8) & 0xff;
                        int a = (uintColor >>  0) & 0xff;
                        outColor = rgba(r, g, b, a / 255.0f);
                        break matchloop;
                    }
                }
                error = "Unexpected char in named color";
                return false;
            }
            next;

            // PERF: there could be something better with a dichotomy
            // PERF: can elid search once we've passed the last match
            bool firstFound = false;
            int firstFoundIndex = R;
            int lastFoundIndex = -1;
            foreach(candindex; L..R)
            {
                // Have we found ch in name[charPos] position?
                string candidate = namedColors[candindex];
                bool charIsMatching = (candidate.length > charPos) 
                                   && (candidate[charPos] == ch);
                if (!firstFound && charIsMatching)
                {
                    firstFound = true;
                    firstFoundIndex = candindex;
                }
                if (charIsMatching)
                    lastFoundIndex = candindex;
            }

            // Zero candidate remain
            if (lastFoundIndex < firstFoundIndex)
            {
                error = "Can't recognize color string";
                return false;
            }
            else
            {
                // Several candidate remain, go on and reduce the 
                // search range
                L = firstFoundIndex;
                R = lastFoundIndex + 1;
                charPos += 1;
            }
        }
    }

    skipWhiteSpace();
    if (!parseChar('\0'))
    {
        error = "Expected end of input at the end of color string";
        return false;
    }

    return true;
}

private:

// 147 predefined color + "transparent"
static immutable string[147 + 1] namedColors =
[
    "aliceblue", "antiquewhite", "aqua", "aquamarine",     
    "azure", "beige", "bisque", "black",
    "blanchedalmond", "blue", "blueviolet", "brown",       
    "burlywood", "cadetblue", "chartreuse", "chocolate",
    "coral", "cornflowerblue", "cornsilk", "crimson",      
    "cyan", "darkblue", "darkcyan", "darkgoldenrod",
    "darkgray", "darkgreen", "darkgrey", "darkkhaki",      
    "darkmagenta", "darkolivegreen", "darkorange", "darkorchid",
    "darkred","darksalmon","darkseagreen","darkslateblue", 
    "darkslategray", "darkslategrey", "darkturquoise", "darkviolet",
    "deeppink", "deepskyblue", "dimgray", "dimgrey",       
    "dodgerblue", "firebrick", "floralwhite", "forestgreen",
    "fuchsia", "gainsboro", "ghostwhite", "gold",          
    "goldenrod", "gray", "green", "greenyellow",
    "grey", "honeydew", "hotpink", "indianred",            
    "indigo", "ivory", "khaki", "lavender",
    "lavenderblush","lawngreen","lemonchiffon","lightblue",
    "lightcoral", "lightcyan", "lightgoldenrodyellow", "lightgray",
    "lightgreen", "lightgrey", "lightpink", "lightsalmon", 
    "lightseagreen", "lightskyblue", "lightslategray", 
                                                     "lightslategrey",
    "lightsteelblue", "lightyellow", "lime", "limegreen",  
    "linen", "magenta", "maroon", "mediumaquamarine",
    "mediumblue", "mediumorchid", "mediumpurple", "mediumseagreen", 
    "mediumslateblue", "mediumspringgreen", "mediumturquoise", 
                                                    "mediumvioletred",
    "midnightblue", "mintcream", "mistyrose", "moccasin",  
    "navajowhite", "navy", "oldlace", "olive",
    "olivedrab", "orange", "orangered",  "orchid",         
    "palegoldenrod", "palegreen", "paleturquoise", "palevioletred",
    "papayawhip", "peachpuff", "peru", "pink",             
    "plum", "powderblue", "purple", "red",
    "rosybrown", "royalblue", "saddlebrown", "salmon",     
    "sandybrown", "seagreen", "seashell", "sienna",
    "silver", "skyblue", "slateblue", "slategray",         
    "slategrey", "snow", "springgreen", "steelblue",
    "tan", "teal", "thistle", "tomato",                    
    "transparent", "turquoise", "violet", "wheat", 
    "white", "whitesmoke", "yellow", "yellowgreen"
];

immutable static uint[147 + 1] namedColorValues =
[
    0xf0f8ffff, 0xfaebd7ff, 0x00ffffff, 0x7fffd4ff, 
    0xf0ffffff, 0xf5f5dcff, 0xffe4c4ff, 0x000000ff, 
    0xffebcdff, 0x0000ffff, 0x8a2be2ff, 0xa52a2aff, 
    0xdeb887ff, 0x5f9ea0ff, 0x7fff00ff, 0xd2691eff, 
    0xff7f50ff, 0x6495edff, 0xfff8dcff, 0xdc143cff, 
    0x00ffffff, 0x00008bff, 0x008b8bff, 0xb8860bff, 
    0xa9a9a9ff, 0x006400ff, 0xa9a9a9ff, 0xbdb76bff, 
    0x8b008bff, 0x556b2fff, 0xff8c00ff, 0x9932ccff, 
    0x8b0000ff, 0xe9967aff, 0x8fbc8fff, 0x483d8bff, 
    0x2f4f4fff, 0x2f4f4fff, 0x00ced1ff, 0x9400d3ff, 
    0xff1493ff, 0x00bfffff, 0x696969ff, 0x696969ff, 
    0x1e90ffff, 0xb22222ff, 0xfffaf0ff, 0x228b22ff, 
    0xff00ffff, 0xdcdcdcff, 0xf8f8ffff, 0xffd700ff, 
    0xdaa520ff, 0x808080ff, 0x008000ff, 0xadff2fff, 
    0x808080ff, 0xf0fff0ff, 0xff69b4ff, 0xcd5c5cff, 
    0x4b0082ff, 0xfffff0ff, 0xf0e68cff, 0xe6e6faff, 
    0xfff0f5ff, 0x7cfc00ff, 0xfffacdff, 0xadd8e6ff, 
    0xf08080ff, 0xe0ffffff, 0xfafad2ff, 0xd3d3d3ff, 
    0x90ee90ff, 0xd3d3d3ff, 0xffb6c1ff, 0xffa07aff, 
    0x20b2aaff, 0x87cefaff, 0x778899ff, 0x778899ff, 
    0xb0c4deff, 0xffffe0ff, 0x00ff00ff, 0x32cd32ff, 
    0xfaf0e6ff, 0xff00ffff, 0x800000ff, 0x66cdaaff, 
    0x0000cdff, 0xba55d3ff, 0x9370dbff, 0x3cb371ff, 
    0x7b68eeff, 0x00fa9aff, 0x48d1ccff, 0xc71585ff, 
    0x191970ff, 0xf5fffaff, 0xffe4e1ff, 0xffe4b5ff, 
    0xffdeadff, 0x000080ff, 0xfdf5e6ff, 0x808000ff, 
    0x6b8e23ff, 0xffa500ff, 0xff4500ff, 0xda70d6ff, 
    0xeee8aaff, 0x98fb98ff, 0xafeeeeff, 0xdb7093ff, 
    0xffefd5ff, 0xffdab9ff, 0xcd853fff, 0xffc0cbff, 
    0xdda0ddff, 0xb0e0e6ff, 0x800080ff, 0xff0000ff, 
    0xbc8f8fff, 0x4169e1ff, 0x8b4513ff, 0xfa8072ff, 
    0xf4a460ff, 0x2e8b57ff, 0xfff5eeff, 0xa0522dff,
    0xc0c0c0ff, 0x87ceebff, 0x6a5acdff, 0x708090ff, 
    0x708090ff, 0xfffafaff, 0x00ff7fff, 0x4682b4ff, 
    0xd2b48cff, 0x008080ff, 0xd8bfd8ff, 0xff6347ff, 
    0x00000000,  0x40e0d0ff, 0xee82eeff, 0xf5deb3ff, 
    0xffffffff, 0xf5f5f5ff, 0xffff00ff, 0x9acd32ff,
];

unittest
{
    import core.stdc.stdio;
    bool doesntParse(string color)
    {
        Color parsed;
        string error;
        if (parseCSSColor(color, parsed, error))
        {
            return false;
        }
        else
            return true;
    }

    bool testParse(string color, ubyte[4] correct)
    {
        Color parsed;
        RGBA8 C = RGBA8(correct[0], correct[1], 
                         correct[2], correct[3]);
        string error;

        if (parseCSSColor(color, parsed, error))
        {
            RGBA8 srgb = parsed.toRGBA8(); 
            if (srgb != C)
            {
                printf("Error: got %d,%d,%d,%d not %d,%d,%d,%d.\n",
                       srgb.r, srgb.g, srgb.b, srgb.a,
                       C.r, C.g, C.b, C.a);
            }
            return srgb == C;
        }
        else
        {
            printf("Error: didn't parse.\n");
            return false;
        }
    }

    assert(doesntParse(""));

    // #hex colors    
    assert(testParse("#aB9" , [0xaa, 0xBB, 0x99, 255]));
    assert(testParse("#aB98" , [0xaa, 0xBB, 0x99, 0x88]));
    assert(doesntParse("#"));
    assert(doesntParse("#ab"));
    assert(testParse(" #0f1c4A " , [0x0f, 0x1c, 0x4a, 255]));    
    assert(testParse(" #0f1c4A43 " , [0x0f, 0x1c, 0x4A, 0x43]));
    assert(doesntParse("#0123456"));
    assert(doesntParse("#012345678"));

    // rgb() and rgba()
    assert(testParse("  rgba( 14.01, 25.0e+0%, 16, 0.5)  " , 
        [14, 64, 16, 128]));
    assert(testParse("rgb(10e3,112,-3.4e-2)"               , 
        [255, 112, 0, 255]));

    // hsl() and hsla()
    assert(testParse("hsl(0   ,  100%, 50%)"         , 
        [255, 0, 0, 255]));
    assert(testParse("hsl(720,  100%, 50%)"          , 
        [255, 0, 0, 255]));
    assert(testParse("hsl(180deg,  100%, 50%)"       , 
        [0, 255, 255, 255]));
    assert(testParse("hsl(0grad, 100%, 50%)"         , 
        [255, 0, 0, 255]));
    assert(testParse("hsl(0rad,  100%, 50%)"         , 
        [255, 0, 0, 255]));
    assert(testParse("hsl(0turn, 100%, 50%)"         , 
        [255, 0, 0, 255]));
    assert(testParse("hsl(120deg, 100%, 50%)"        , 
        [0, 255, 0, 255]));
    assert(testParse("hsl(123deg,   2.5%, 0%)"       , 
        [0, 0, 0, 255]));
    assert(testParse("hsl(5.4e-5rad, 25%, 100%)"     , 
        [255, 255, 255, 255]));
    assert(testParse("hsla(0turn, 100%, 50%, 0.25)"  , 
        [255, 0, 0, 64]));

    // gray values
    assert(testParse(" gray( +0.0% )"       , [0, 0, 0, 255]));
    assert(testParse(" gray "               , [128, 128, 128, 255]));
    assert(testParse(" gray( 100%, 50% ) "  , [255, 255, 255, 128]));

    // Named colors
    assert(testParse("tRaNsPaREnt"  , [0, 0, 0, 0]));
    assert(testParse(" navy "  , [0, 0, 128, 255]));
    assert(testParse("lightgoldenrodyellow"  , [250, 250, 210, 255]));
    assert(doesntParse("animaginarycolorname")); // unknown name
    assert(doesntParse("navyblahblah")); // too much chars
    assert(doesntParse("blac")); // incomplete color
    assert(testParse("lime"  , [0, 255, 0, 255])); // 2 candidates
    assert(testParse("limegreen"  , [50, 205, 50, 255]));    
}

// <copied from dplug:core to avoid a dependency>

// C-locale independent string to float parsing.
// Params:
//     s Must be a zero-terminated string.
//     mustConsumeEntireInput if true, check that s is entirely 
//     consumed by parsing the number.
//     err: optional bool
public double convertStringToDouble(const(char)* s, 
                                    bool mustConsumeEntireInput,
                                    bool* err) pure nothrow @nogc
{
    if (s is null)
    {
        if (err) *err = true;
        return 0.0;
    }

    const(char)* end;
    bool strtod_err = false;
    double r = stb__clex_parse_number_literal(s, &end, 
        &strtod_err, true);

    if (strtod_err)
    {
        if (err) *err = true;
        return 0.0;
    }

    if (mustConsumeEntireInput)
    {
        size_t len = strlen(s);
        if (end != s + len)
        {
            if (err) *err = true; // did not consume whole string
            return 0.0;
        }
    }

    if (err) *err = false; // no error
    return r;
}

double stb__clex_parse_number_literal(const(char)* p, 
                                      const(char)**q, 
                                      bool* err,
                                      bool allowFloat) 
    pure nothrow @nogc 
{
    const(char)* s = p;
    double value=0;
    int base=10;
    int exponent=0;
    int signMantissa = 1;

    // Skip leading whitespace, like scanf and strtod do
    while (true)
    {
        char ch = *p;
        if (ch == ' ' || ch == '\t' || ch == '\r' 
            || ch == '\n' || ch == '\f' || ch == '\r')
        {
            p += 1;
        }
        else
            break;
    }


    if (*p == '-') 
    {
        signMantissa = -1;
        p += 1;
    } 
    else if (*p == '+') 
    {
        p += 1;
    }

    if (*p == '0') 
    {
        if (p[1] == 'x' || p[1] == 'X') 
        {
            base=16;
            p += 2;
        }
    }

    for (;;) 
    {
        if (*p >= '0' && *p <= '9')
            value = value*base + (*p++ - '0');
        else if (base == 16 && *p >= 'a' && *p <= 'f')
            value = value*base + 10 + (*p++ - 'a');
        else if (base == 16 && *p >= 'A' && *p <= 'F')
            value = value*base + 10 + (*p++ - 'A');
        else
            break;
    }

    if (allowFloat)
    {
        if (*p == '.') 
        {
            double pow, addend = 0;
            ++p;
            for (pow=1; ; pow*=base) 
            {
                if (*p >= '0' && *p <= '9')
                    addend = addend*base + (*p++ - '0');
                else if (base == 16 && *p >= 'a' && *p <= 'f')
                    addend = addend*base + 10 + (*p++ - 'a');
                else if (base == 16 && *p >= 'A' && *p <= 'F')
                    addend = addend*base + 10 + (*p++ - 'A');
                else
                    break;
            }
            value += addend / pow;
        }
        if (base == 16) {
            // exponent required for hex float literal, 
            // else it's an integer literal like 0x123
            exponent = (*p == 'p' || *p == 'P');
        } else
            exponent = (*p == 'e' || *p == 'E');

        if (exponent) 
        {
            int sign = p[1] == '-';
            uint exponent2 = 0;
            double power=1;
            ++p;
            if (*p == '-' || *p == '+')
                ++p;
            while (*p >= '0' && *p <= '9')
                exponent2 = exponent2*10 + (*p++ - '0');

            if (base == 16)
                power = stb__clex_pow(2, exponent2);
            else
                power = stb__clex_pow(10, exponent2);
            if (sign)
                value /= power;
            else
                value *= power;
        }
    }

    if (q) *q = p;
    if (err) *err = false; // seen no error

    if (signMantissa < 0)
        value = -value;

    if (!allowFloat)
    {
        // clamp and round to nearest integer
        if (value > int.max) value = int.max;
        if (value < int.min) value = int.min;
    }    
    return value;
}

double stb__clex_pow(double base, uint exponent) pure
    nothrow @nogc
{
    double value=1;
    for ( ; exponent; exponent >>= 1) {
        if (exponent & 1)
            value *= base;
        base *= base;
    }
    return value;
}

// </copied from dplug:core to avoid a dependency>