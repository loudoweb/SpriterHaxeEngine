package spriter.definitions;
#if openfl
import openfl.geom.Point;
#elseif flambe
import flambe.math.Point;
#elseif luxe
typedef Point = phoenix.Vector;
#end

/**
 * Spriter box that can be useful to check collision.
 * Spriter manual: http://www.brashmonkey.com/spriter_manual/adding%20collision%20rectangles%20to%20frames.htm
 * @author Loudo
 */
class Quadrilateral
{
	public var p1:Point;
	public var p2:Point;
	public var p3:Point;
	public var p4:Point;
	public function new(p1:Point, p2:Point, p3:Point, p4:Point) 
	{
		this.p1 = p1;
		this.p2 = p2;
		this.p3 = p3;
		this.p4 = p4;
	}
}