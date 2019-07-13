package test;

import haxe.unit.TestCase;
import spriter.engine.SpriterEngine;
import spriter.library.AbstractLibrary;
import spriter.util.SpriterUtil;
import spriter.definitions.SpatialInfo;

/**
 * Test cases for very common scenarios.
 */
class BasicTestCase extends TestCase
{
    public function new()
    {
        super();
    }

    public function testConstructEngine():Void
    {
        var lib:AbstractLibrary = null;
        var x:SpriterEngine = new SpriterEngine("", null, lib);

        // At least one assert is needed to make the unit test pass
        assertTrue(true);
    }

    public function testSpriterUtilClearArray():Void
    {
        // Construct an array that results in an ArrayDyn in HashLink
        var array:Array<Dynamic> = [1, 2];

        // The original version set the length property, which fails when the underlying type is an ArrayDyn.
        SpriterUtil.clearArray(array);
        assertTrue(array.length == 0);
    }
}