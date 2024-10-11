import std.stdio;
import colors;

void main(string[] args)
{
	foreach(arg; args[1..$])
	{
    	RGBA8 c = color(arg).toRGBA8;
    	writefln("CSS color '%s' is %s,%s,%s,%s", arg, c.r, c.g, c.b, c.a);
    }
}