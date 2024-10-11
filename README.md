# Colors

`colors` DUB package is a CSS color parsing libraries.
It defines basic types for colors, and a monomorphic `Color` type to 
use as interchange.

_The problem is that screens and CSS now support the P3 colorspace, the 
end-goal is to be ready for more conversions than just staying 8-bit 
sRGB forever._

**This is a work in progress. Only sRGB supported for now.**


## Current features

- `rgb` and `rgba` functions, return a `Color`
- `hsl` and `hsla` functions, return a `Color`
- `Color.toRGBA8()` to get a 8-bit sRGB quadruplet
- `Color.toRGBAf()` to get a 32-bit float sRGB quadruplet
- `nothrow @nogc @safe`
- See `test-suite/` for exact syntax supported, the goal is to follow 
  CSS recommendations.


## Parsing a color strinc

```d
import colors;

Color c;
string err;
if (parseCSSColor(str, c, err)) {
    // do something with c
}
else
    throw new Exception(err);
```