import colors;
import consolecolors;
import std.math;
import std.format;

void main()
{
	testRGB();
}

class Result
{
    string model;
    double[4] value;

    this(string model, double[4] value)
    {
        this.model = model;
        this.value = value;
    }

    override string toString()
    {
        int r = cast(int)(0.5 + 255 * value[0]);
        int g = cast(int)(0.5 + 255 * value[1]);
        int b = cast(int)(0.5 + 255 * value[2]);
        return format("rgba(%s, %s, %s, %s)", r, g, b, value[3]);
    }

    bool isSameValueAs(RGBA8 color)
    {
        int r = cast(int)(0.5 + value[0]);
        if (r != color.r)
            return false;   
        int g = cast(int)(0.5 + value[1]);
        if (g != color.g)
            return false;
        int b = cast(int)(0.5 + value[2]);
        if (b != color.b)
            return false;
        if (abs(value[3] - color.a / 255) > 0.2)
            return false;
        return true;
    }
}

class Options
{
    bool isLevel4;

    this(bool level4)
    {
        this.isLevel4 = level4;
    }
}

void testRGB()
{
    int numTest = 1;

    void test(string colorString, Result result, string desc, Options opt = null)
    {
        cwritefln(" <white>*** TEST %d: %s</white>", numTest++, desc);
        cwritefln("    <green>Parse</green> color string <yellow>%s</yellow>", colorString);


        ubyte[4] srgb = [0, 0, 0, 0];

        Color color;
        string err;
        bool colorIsCorrect = true;
        bool success = parseCSSColor(colorString, color, err);
        if (!success)
            cwritefln("    Returned an error with message <lcyan>%s</lcyan>", err);
        else
        {
            RGBA8 rgba = color.toRGBA8();
            srgb[0] = rgba.r;
            srgb[1] = rgba.g;
            srgb[2] = rgba.b;
            srgb[3] = rgba.a;
            cwritefln("    Returned a Color (<yellow>%d, %d, %d, %d</yellow>) (as sRGB 8-bit)",
                      rgba.r, rgba.g, rgba.b, rgba.a);

            colorIsCorrect = result.isSameValueAs(rgba);
            if (!colorIsCorrect)
            {
                cwritefln("    but expected Color <cyan>%s</cyan>)", result);
                success = false;
            }
        }

        if (result !is null && colorIsCorrect)
        {
        }

        if (result is null && success)
            cwriteln("    <lred>FAIL</lred>: accept invalid");
        if (result !is null && !success)
            cwriteln("    <lred>FAIL</lred> rejects valid");
        if (result is null && !success)
            cwriteln("    <lgreen>SUCCESS</lgreen> rejects invalid");
        if (result !is null && success)
        {
            cwriteln("    <lgreen>SUCCESS</lgreen> accepts valid and parses OK");
        }

        cwriteln;
    }

    test("rgb(30.7, 60.6, 41.2)",            new Result("rgb", [31, 61, 41, 1]                ), "rgb() with decimals", new Options(true));
    test("rgb(.4, .4, .4)",                  new Result("rgb", [0, 0, 0, 1]                   ), "rgb() with decimals without leading digits", new Options(true));
    test("rgb(5.5%, 10.875%, 32.25%)",       new Result("rgb", [14, 28, 82, 1]                ), "rgb() with decimal percentages");
    test("rgb(5..5%, 10....875%, 32...25%)", null, "rgb() percentages with multiple decimal points");
    test("rgb(-5%, 10.875%, -32.25%)",       new Result("rgb", [0, 28, 0, 1]) , "rgb() with negative percentages");
    test("rgb(+5%, 10.875%, +32.25%)",       new Result("rgb", [14, 28, 82, 1]) , "rgb() with unary-positive percentages");
    test("rgb(300, 170, 750)",               new Result("rgb", [255, 170, 255, 1]) , "rgb() with above-maximum numbers");
    test("rgb(-132, 170, -72)",              new Result("rgb", [0, 170, 0, 1]) , "rgb() with negative numbers");
    test("rgb(+132, +170, +73)",             new Result("rgb", [132, 170, 73, 1]) , "rgb() with unary-positive numbers");
    test("rgb(+132+170+73)",                 new Result("rgb", [132, 170, 73, 1]) , "rgb() with unary-positive numbers and no spaces", new Options(true));
    test("rgb(.4.4.4)",                      new Result("rgb", [0, 0, 0, 1]) , "no-comma rgb() without any spaces", new Options(true));
    test("rgb(30e+0, 57000e-3, 4.0e+1)",     new Result("rgb", [30, 57, 40, 1]) , "rgb() with scientific notation", new Options(true));
    test("rgb(30e+0%, 57000e-3%, 4e+1%)",    new Result("rgb", [77, 145, 102, 1]) , "rgb() with scientific notation percentages");
    test("rgb(128, 192, 64",                 new Result("rgb", [128, 192, 64, 1]) , "rgb() with missing close-paren");
    test("rgb(   132,    170, 73    )",      new Result("rgb", [132, 170, 73, 1]) , "rgb() with extra spaces inside parentheses");
    test("rgb(132 , 170 , 73)",              new Result("rgb", [132, 170, 73, 1]) , "rgb() with spaces before commas");
    test("rgb(132,170,73)",                  new Result("rgb", [132, 170, 73, 1]) , "rgb() with commas but no spaces");
    test("rgb(\n132,\n170,\n73\n)",          new Result("rgb", [132, 170, 73, 1]) , "rgb() with newlines");
    test("rgb(\t132,\t170,\t73\t)",          new Result("rgb", [132, 170, 73, 1]) , "rgb() with tabs");
    test("rgba(132, 170, 73, 1, 0.5)", null, "rgba() with too many components");
    test("rgba(132, 170)", null, "rgba() with not enough components");
    test("rgb(132, 170, 73, 1, 0.5)", null, "rgb() with too many components");
    test("rgb(132, 170)", null, "rgb() with not enough components");
    test("rgb 132, 170, 73", null, "rgb with no parentheses");
    test("rgb132,170,73", null, "rgb with no parentheses or spaces");
    test("rgb (132, 170, 73)", null, "rgb () with space before opening parenthesis");
    test("rgb(132, 170, 73)garbage", null, "rgb() with extra garbage after");
    test("rgb(5%, 50, 30%)", null, "rgb() with mixed percentages/numbers");
    test("rgb(3e, 50, 30)", null, "rgb() with an \"e\" where it should not be");
    test("rgb(3blah, 50, 30)", null, "rgb() with extra letters after values");
    test("rgb(50 50, 30)", null, "rgb() with mixed commas/no commas", new Options(true));
    test("RGB(132, 170, 73)",                 new Result("rgb", [132, 170, 73, 1]), "RGB() in uppercase");
    test("RgB(132, 170, 73)",                 new Result("rgb", [132, 170, 73, 1]), "RgB() in mixed case");
    test("rgba(132, 170, 73, 5e-1)",          new Result("rgb", [132, 170, 73, 0.5]), "rgba() with scientific notation alpha");
    test("rgb(132 170 73 0.5)", null, "rgb() with no commas and no slash before alpha", new Options(true));
    test("rgb(132 / 170 / 73 / 0.5)", null, "rgb() with all slashes", new Options(true));
}
