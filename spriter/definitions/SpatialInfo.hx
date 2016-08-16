package spriter.definitions;
import spriter.interfaces.ISpriterPooled;
import spriter.util.SpriterPool;
import spriter.util.SpriterUtil;

/**
 * ...
 * @author Loudo
 */
class SpatialInfo implements ISpriterPooled 
{
	public var x:Float = 0; 
    public var y:Float = 0; 
    public var angle:Float = 0;
    public var scaleX:Float = 1; 
    public var scaleY:Float = 1; 
	/**
	 * Alpha
	 */
    public var a:Float = 1;
    public var spin:Int = 1;
	
	private static var _pool = new SpriterPool<SpatialInfo>(SpatialInfo);
	private var _inPool:Bool = false;
	
	/**
	 * Recycle or create a new SpatialInfo. 
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @return	This point.
	 */
	public static inline function get(x:Float = 0, y:Float = 0, angle:Float = 0, scaleX:Float = 1, scaleY:Float = 1, a:Float = 1, spin:Int = 1):SpatialInfo
	{
		var pooledInfo = _pool.get().init(x, y, angle, scaleX, scaleY, a, spin);
		pooledInfo._inPool = false;
		return pooledInfo;
	}
	
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
	
	public function init(x:Float = 0, y:Float = 0, angle:Float = 0, scaleX:Float = 1, scaleY:Float = 1, a:Float = 1, spin:Int = 1):SpatialInfo
	{
		this.x = x; 
		this.y = y; 
		this.angle = angle;
		this.scaleX = scaleX; 
		this.scaleY = scaleY; 
		this.a = a;
		this.spin = spin;
		return this;
	}
	
	public function setPos(x:Float = 0, y:Float = 0):SpatialInfo
	{
		this.x = x; 
		this.y = y; 
		return this;
	}
	
	public function setScale(scale:Float):SpatialInfo
	{
		this.scaleX = scale; 
		this.scaleY = scale;
		return this;
	}
	/**
	 * 
	 * @param	parentInfo
	 * @param	out if null, this method will override this SpatialInfo
	 * @return
	 */
	public function unmapFromParent(parentInfo:SpatialInfo, out:SpatialInfo = null):SpatialInfo
    {
		if (out == null)
			out = this;
		else
			out.init(x, y, angle, scaleX, scaleY, a, spin);//initializing the out object with the values of this object
		
		if (parentInfo.scaleX * parentInfo.scaleY < 0)
			out.angle *= -1; //allow flipping using negative scaling
			
		out.angle += parentInfo.angle;
		out.scaleX *= parentInfo.scaleX;
		out.scaleY *= parentInfo.scaleY;
		out.a *= parentInfo.a;
		
		if (out.x != 0 || out.y != 0)
		{
			var preMultX = out.x * parentInfo.scaleX;
			var preMultY = out.y * parentInfo.scaleY;
			var parentRad = SpriterUtil.toRadians(SpriterUtil.under360(parentInfo.angle));
			var s = Math.sin(parentRad);
			var c = Math.cos(parentRad);
			
			out.x = (preMultX * c) - (preMultY * s) + parentInfo.x;
			out.y = (preMultX * s) + (preMultY * c) + parentInfo.y;
		}
		else
		{
			out.x = parentInfo.x;
			out.y = parentInfo.y;
		}
		
		return out;
    }
	
	inline public function copy():SpatialInfo
	{
		return new SpatialInfo(x, y, angle, scaleX, scaleY, a, spin);
	}
	public function clone(out:SpatialInfo):Void
	{
		out.init(x, y, angle, scaleX, scaleY, a, spin);//initializing the out object with the values of this object
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
	/**
	 * Add this SpatialInfo to the recycling pool.
	 */
	public function put():Void
	{
		if (!_inPool)
		{
			_inPool = true;
			_pool.putUnsafe(this);
		}
	}
	public function destroy():Void
	{
		
	}
	
	public function toString():String
	{
		return '[SpatialInfo: $x, $y, $scaleX, $scaleY, $angle, $a]';
	}
	
}