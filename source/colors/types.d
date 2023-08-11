module colors.types;

nothrow @nogc @safe:

import colors.conversions;


/// The CSS Predefined Color Spaces.
enum Colorspace
{
	/// The sRGB predefined color space defined below is the same as is used for legacy sRGB 
    /// colors, such as rgb().
	srgb,

	/// The sRGB-linear predefined color space is the same as srgb except that the transfer 
    /// function is linear-light (there is no gamma-encoding).
	srgbLinear,

    /*

    display-p3	10
    a98-rgb	10
    prophoto-rgb	12
    rec2020	12

    xyz, xyz-d50, xyz-d65	16
    */
    /*
	lab,
	oklab,
	xyz,
	xyz_d50,
	xyz_d65 */
}


/// The Color type holds both a (runtime) color type and value.
/// This correspond to both "specified", "computed", and "used" colors in CSS.
/// In typical usage, you will want to map to sRGB 32-bit RGBA quadruplet.
/// Basically a tagged union.
/// Reference: https://www.w3.org/TR/css-color-4/
struct Color
{
public:

	/// CSS spec recommends:
	/// "(16bit, half-float, or float per component is recommended for internal storage). 
    /// Values must be rounded towards +∞, not truncated."
	union
    {
		struct
        {
			float r, g, b, a;
        }
    }

private:
	Colorspace colorSpace;
}


/// The `rgb` function is the same as in CSS color specifications.
/// Instead of being either numbers or percentages, all values here 
/// are assumed to be numbers from 0 to 255. However, internally the 
/// color will be stored with higher accuracy, as per CSS spec.
Color rgb(float r, float g, float b, float a = 255.0f)
{
	Color c;
	c.r = r;
	c.g = g;
	c.b = b;
	c.a = a;
	c.colorSpace = Colorspace.srgb;
	return c;
}

/// In CSS, `rgba` is simply in alias of `rgb`. You can specify an alpha to `rgb`, or omit it with 
/// `rgba`.
alias rgba = rgb;


/// The `hsl` function is the same as in CSS color specifications.




