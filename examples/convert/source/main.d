import std.stdio;
import colors;

void main(string[] args)
{
	foreach(arg; args[1..$])
	{
    	RGBA8 c8 = color(arg).toRGBA8;
        RGBA16 c16 = color(arg).toRGBA16;
        RGBAf c32 = color(arg).toRGBAf;
    	writefln("CSS color '%s' is:", arg);
        writefln("  - as 8-bit sRGB => %s,%s,%s,%s", c8.r, c8.g, c8.b, c8.a);
        writefln("  - as 16-bit sRGB => %s,%s,%s,%s", c16.r, c16.g, c16.b, c16.a);
        writefln("  - as 32-bit float sRGB => %s,%s,%s,%s", c32.r, c32.g, c32.b, c32.a);
        writeln;
    }
}