package spriter.definitions;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class SpatialInfo
{
	public var x:Float=0; 
    public var y:Float=0; 
    public var angle:Float=0;
    public var scaleX:Float=1; 
    public var scaleY:Float=1; 
	/**
	 * Alpha
	 */
    public var a:Float=1;
    public var spin:Int=1;
	
	public function new(x:Float = 0, y:Float = 0, angle:Float = 0, scaleX:Float = 1, scaleY:Float = 1, a:Float = 1, spin:Int = 1) 
	{
		this.x = x; 
		this.y = y; 
		this.angle = angle;
		this.scaleX = scaleX; 
		this.scaleY = scaleY; 
		this.a = a;
		this.spin = spin;
	}
	
	public function unmapFromParent(parentInfo:SpatialInfo):SpatialInfo
    {
        var unmapped_x : Float;
		var unmapped_y : Float;
		var unmapped_angle = angle + parentInfo.angle;
		var unmapped_scaleX = scaleX * parentInfo.scaleX;
		var unmapped_scaleY = scaleY * parentInfo.scaleY;
		var unmapped_alpha = a * parentInfo.a;
		
		if (x != 0 || y != 0)
		{
			var preMultX = x * parentInfo.scaleX;
			var preMultY = y * parentInfo.scaleY;
			var parentRad = SpriterUtil.toRadians(SpriterUtil.under360(parentInfo.angle));
			var s = Math.sin(parentRad);
			var c = Math.cos(parentRad);
			
			unmapped_x = (preMultX * c) - (preMultY * s) + parentInfo.x;
			unmapped_y = (preMultX * s) + (preMultY * c) + parentInfo.y;
		}
		else
		{
			unmapped_x = parentInfo.x;
			unmapped_y = parentInfo.y;
		}
		
		return new SpatialInfo(unmapped_x, unmapped_y, unmapped_angle, unmapped_scaleX, unmapped_scaleY, unmapped_alpha, spin);
    }
	
	public function copy():SpatialInfo
	{
		var c:SpatialInfo = new SpatialInfo(x, y, angle, scaleX, scaleY, a, spin);
		return c;
	}
	
	/*public function linear(infoA:SpatialInfo, infoB:SpatialInfo, spin:Int, t:Float):SpatialInfo
	{
		var resultInfo:SpatialInfo;
		resultInfo.x = linear(infoA.x,infoB.x,t); 
		resultInfo.y = linear(infoA.y,infoB.y,t);  
		resultInfo.angle = angleLinear(infoA.angle,infoB.angle,spin,t); 
		resultInfo.scaleX = linear(infoA.scaleX,infoB.scaleX,t); 
		resultInfo.scaleY = linear(infoA.scaleY,infoB.scaleY,t); 
		resultInfo.a = linear(infoA.a,infoB.a,t); 
	}*/
	
}