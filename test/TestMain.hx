package test;

import haxe.unit.TestRunner;

class TestMain
{
    public static function main():Void
    {
        var runner = new TestRunner();
        runner.add(new BasicTestCase());
        runner.run();
    }
}
