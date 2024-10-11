# Colors

`colors` DUB package is a CSS color parsing libraries.
It defines basic types for colors, and a **monomorphic** `Color` type to 
use as interchange.

_The problem is that screens and CSS now support the P3 colorspace, the 
end-goal is to be ready for more conversions than just staying sRGB forever. Color will be able to "do it all", in the future._

**This is a work in progress. Only sRGB supported for now.**


## Current features
- 🎨 `color()` function to parse a [CSS color](https://www.w3schools.com/cssref/css_colors_legal.php) string.
- 🎨 `rgb()` and `rgba()` functions, return a `Color`
- 🎨 `hsl()` and `hsla()` functions, return a `Color`
- 🎨 `Color.toRGBA8()` to get a 8-bit sRGB quadruplet
- 🎨 `Color.toRGBAf()` to get a 32-bit float sRGB quadruplet
- 🎨 `nothrow @nogc @safe`
- 🎨 See `test-suite/` for exact syntax supported, the goal is to follow 
  CSS recommendations.


## Tip: Parsing a color string

```d
import colors;

// Quick way:
Color c = color("red");
Color c = Color("blue"); // also works

// More correct way:
string err;
if (!parseCSSColor(str, c, err)) 
    throw new Exception(err);
```

## Making it useful

```d
import std.stdio;
import colors;

void main()
{
    RGBA8 c = color("coral").toRGBA8;
    writefln("c is %s,%s,%s,%s", c.r, c.g, c.b, c.a);
}
```
