package spriter.library;
import spriter.definitions.PivotInfo;
import spriter.definitions.Quadrilateral;
import spriter.definitions.SpatialInfo;
import spriter.util.SpriterUtil;
#if openfl
import openfl.geom.Point;
#elseif flambe
import flambe.math.Point;
#end

/**
 * ...
 * @author Loudo
 */
class AbstractLibrary
{
	private var _basePath:String;

	
	
	/**
	 * 
	 * @param	_basePath 
	 */
	public function new(basePath :String) 
	{
		_basePath = basePath;
	}
	
	/**
	 * 
	 * @param	name of the image
	 * @return  dynamic
	 */
	public function getFile(name:String):Dynamic
	{
		throw ("must be overrided");
		return null;
	}
	
	public function clear():Void
	{
		throw ("must be overrided");
	}
	
	public function addGraphic(name:String, info:SpatialInfo, pivots:PivotInfo):Void
	{
		throw ("must be overrided");
	}
	
	public function compute(info:SpatialInfo, pivots:PivotInfo, width:Float, height:Float):SpatialInfo
	{
		var degreesUnder360 = SpriterUtil.under360(info.angle);
		var rad = SpriterUtil.toRadians(degreesUnder360);
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		
		var pivotX =  info.x;
		var pivotY =  info.y;
		
		var preX = info.x - pivots.pivotX * width * info.scaleX;
		var preY = info.y + (1 - pivots.pivotY) * height * info.scaleY;	
		
		var x2 = (preX - pivotX) * c - (preY - pivotY) * s + pivotX;
        var y2 = (preX - pivotX) * s + (preY - pivotY) * c + pivotY;
		return info.init(x2, -y2, degreesUnder360, info.scaleX, info.scaleY, info.a, info.spin);//TODO pool?
	}
	
	public function computeRectCoordinates(info:SpatialInfo, pivots:PivotInfo, width:Float, height:Float):Quadrilateral
	{
		var degreesUnder360 = -SpriterUtil.under360(info.angle);
		var rad = SpriterUtil.toRadians(degreesUnder360);
		var s = Math.sin(rad);
		var c = Math.cos(rad);
		
		var pivotX = info.x;
		var pivotY = -info.y;
		
		//1
		var x1 = pivotX - width * info.scaleX * pivots.pivotX;
		var y1 = pivotY - height * info.scaleY * (1 - pivots.pivotY);
		
		//2
 		var x2 = x1 + width * info.scaleX;
		var y2 = y1;
		
		x2 = (x2 - pivotX) * c - (y2 - pivotY) * s + pivotX;
		y2 = (x2 - pivotX) * s + (y2 - pivotY) * c + pivotY;
		
		//3
		var x3 = x1 + width * info.scaleX;
		var y3 = y1 + height * info.scaleY;	
		
		x3 = (x3 - pivotX) * c - (y3 - pivotY) * s + pivotX;
		y3 = (x3 - pivotX) * s + (y3 - pivotY) * c + pivotY;
		
		//4
		var x4 = x1;
		var y4 = y1 + height * info.scaleY;	
		
		x4 = (x4 - pivotX) * c - (y4 - pivotY) * s + pivotX;
		y4 = (x4 - pivotX) * s + (y4 - pivotY) * c + pivotY;
		
		x1 = (x1 - pivotX) * c - (y1 - pivotY) * s + pivotX;
		y1 = (x1 - pivotX) * s + (y1 - pivotY) * c + pivotY;
		
		return new Quadrilateral(new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), new Point(x4, y4));//TODO pool?
	}
	
	public function render():Void
	{
		
	}
	
	public function destroy():Void
	{
		
	}
	
}