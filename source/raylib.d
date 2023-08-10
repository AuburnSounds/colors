module colors.raylib;

/// This is a 32-bit R8G8B8A8 color type with same API as Raylib.
/// Obviously dRGB is implied, the API was copied because the documentation is nice with the Raylib
/// cheat sheets: https://www.raylib.com/cheatsheet/cheatsheet.html
struct RayColor
{
nothrow @nogc pure @safe:
public:

    /// Red.
    ubyte r = 0;

    /// Green.
    ubyte g = 0;

    /// Blue.
    ubyte b = 0;

    /// Alpha.
    ubyte a = 0;

private:
   
}

// Custom raylib color palette for amazing visuals on WHITE background
enum RayColor LIGHTGRAY  = RayColor(200, 200, 200, 255); /// Light Gray
enum RayColor GRAY       = RayColor(130, 130, 130, 255); /// Gray
enum RayColor DARKGRAY   = RayColor( 80,  80,  80, 255); /// Dark Gray
enum RayColor YELLOW     = RayColor(253, 249,   0, 255); /// Yellow
enum RayColor GOLD       = RayColor(255, 203,   0, 255); /// Gold
enum RayColor ORANGE     = RayColor(255, 161,   0, 255); /// Orange
enum RayColor PINK       = RayColor(255, 109, 194, 255); /// Pink
enum RayColor RED        = RayColor(230,  41,  55, 255); /// Red
enum RayColor MAROON     = RayColor(190,  33,  55, 255); /// Maroon
enum RayColor GREEN      = RayColor(  0, 228,  48, 255); /// Green
enum RayColor LIME       = RayColor(  0, 158,  47, 255); /// Lime
enum RayColor DARKGREEN  = RayColor(  0, 117,  44, 255); /// Dark Green
enum RayColor SKYBLUE    = RayColor(102, 191, 255, 255); /// Sky Blue
enum RayColor BLUE       = RayColor(  0, 121, 241, 255); /// Blue
enum RayColor DARKBLUE   = RayColor(  0,  82, 172, 255); /// Dark Blue
enum RayColor PURPLE     = RayColor(200, 122, 255, 255); /// Purple
enum RayColor VIOLET     = RayColor(135,  60, 190, 255); /// Violet
enum RayColor DARKPURPLE = RayColor(112,  31, 126, 255); /// Dark Purple
enum RayColor BEIGE      = RayColor(211, 176, 131, 255); /// Beige
enum RayColor BROWN      = RayColor(127, 106,  79, 255); /// Brown
enum RayColor DARKBROWN  = RayColor( 76,  63,  47, 255); /// Dark Brown
enum RayColor WHITE      = RayColor(255, 255, 255, 255); /// White
enum RayColor BLACK      = RayColor(  0,   0,   0, 255); /// Black
enum RayColor BLANK      = RayColor(  0,   0,   0,   0); /// Blank (Transparent)
enum RayColor MAGENTA    = RayColor(255,   0, 255, 255); /// Magenta
enum RayColor RAYWHITE   = RayColor(245, 245, 245, 255); /// My own White (raylib logo)


/// Color/pixel related functions.
/// Get color with alpha applied, alpha goes from 0.0f to 1.0f.
RayColor Fade(RayColor color, float alpha)
{
    return RayColor.init;
}

/// Get hexadecimal value for a Color.
int ColorToInt(RayColor color)
{
    return 0;
}

/// Get Color normalized as float [0..1].
float[4] ColorNormalize(RayColor color)
{
    return (float[4]).init;
}

/// Get Color from normalized values [0..1].
RayColor ColorFromNormalized(float[4] normalized)
{
    return RayColor.init;
}

/// Get HSV values for a Color, hue [0..360], saturation/value [0..1].
float[3] ColorToHSV(RayColor color)
{
    return (float[3]).init;
}

/// Get a Color from HSV values, hue [0..360], saturation/value [0..1].
RayColor ColorFromHSV(float hue, float saturation, float value)
{
    return RayColor.init;
}

/// Get color multiplied with another color.
RayColor ColorTint(RayColor color, RayColor tint)
{
    return RayColor.init;
}

/// Get color with brightness correction, brightness factor goes from -1.0f to 1.0f.
RayColor ColorBrightness(RayColor color, float factor)
{
    return RayColor.init;
}

/// Get color with contrast correction, contrast values between -1.0f and 1.0f.
RayColor ColorContrast(RayColor color, float contrast)
{
    return RayColor.init;
}

/// Get color with alpha applied, alpha goes from 0.0f to 1.0f.
RayColor ColorAlpha(RayColor color, float alpha)
{
    return RayColor.init;
}

/// Get src alpha-blended into dst color with tint.
RayColor ColorAlphaBlend(RayColor dst, RayColor src, RayColor tint)
{
    return RayColor.init;
}

/// Get Color structure from hexadecimal value.
RayColor GetColor(uint hexValue)
{
    return RayColor.init;
}

//Color GetPixelColor(void *srcPtr, int format);                        // Get Color from a source pixel pointer of certain format
//void SetPixelColor(void *dstPtr, Color color, int format);            // Set color formatted into destination pixel pointer
//int GetPixelDataSize(int width, int height, int format);              // Get pixel data size in bytes for certain format