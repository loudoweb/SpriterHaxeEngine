package spriter.definitions;
import openfl.geom.Point;

/**
 * ...
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