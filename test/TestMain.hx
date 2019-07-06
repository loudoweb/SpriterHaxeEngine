package test;

using haxe.unit.TestRunner;

class TestMain
{
    public static function main():Void
    {
        var runner = new TestRunner();
        runner.add(new ConstructEngineTestCase());
        runner.run();
    }
}
