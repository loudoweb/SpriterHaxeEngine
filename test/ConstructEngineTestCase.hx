package test;

using haxe.unit.TestCase;
using spriter.engine.SpriterEngine;
using spriter.library.AbstractLibrary;

class ConstructEngineTestCase extends TestCase
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
}