package spriter.definitions;
import haxe.xml.Fast;
import spriter.definitions.TimelineKey.CurveType;

/**
 * ...
 * @author Loudo
 */
enum CurveType
{
	INSTANT;
	LINEAR;
	QUADRATIC;
	CUBIC;
}
 
class TimelineKey
{
	public var id:Int;
	public var time:Int = 0;
    public var curveType:CurveType; // enum : INSTANT,LINEAR,QUADRATIC,CUBIC
    public var  c1:Float; 
    public var  c2:Float; 
	
	public function new(fast:Fast = null) 
	{
		if(fast != null){
			id = fast.has.id ? Std.parseInt(fast.att.id) : 0;
			time = fast.has.time ? Std.parseInt(fast.att.time) : 0;
			curveType = fast.has.curve_type ? Type.createEnum(CurveType, fast.att.curve_type.toUpperCase()) : CurveType.LINEAR;
			c1 = fast.has.c1 ? Std.parseFloat(fast.att.c1) : 0;
			c2 = fast.has.c2 ? Std.parseFloat(fast.att.c2) : 0;
		}
	}
	
	public function copy ():TimelineKey
	{
		var	copy:TimelineKey = new TimelineKey();
		return clone (copy);
	}

	public function clone (clone:TimelineKey):TimelineKey
	{
		clone.id = id;
		clone.time = time;
		clone.curveType = curveType;
		clone.c1 = c1;
		clone.c2 = c2;
		return clone;
	}
	
	public function interpolate(nextKey:TimelineKey, nextKeyTime:Int, currentTime:Float):Void
    {
        linearKey(nextKey, getTWithNextKey(nextKey, nextKeyTime, currentTime));
    }           

    public function getTWithNextKey(nextKey:TimelineKey, nextKeyTime:Int, currentTime:Float):Float
    {
        if(curveType == INSTANT || time == nextKey.time)
        {
            return 0;
        }
        
        var t:Float = (currentTime - time) / (nextKey.time - time);

        if(curveType == LINEAR)
        {
            return t;        
        }
        else if(curveType == QUADRATIC)
        {
            return(quadratic(0.0,c1,1.0,t));
        }
        else if(curveType == CUBIC)
        {  
            return(cubic(0.0,c1,c2,1.0,t));
        }
    
        return 0; // Runtime should never reach here        
    }	

    public function linear(a:Float, b:Float, t:Float):Float
    {
		return ((b-a)*t)+a;
    }
	public function linearKey (keyB:TimelineKey, t:Float):Void
	{
		// overridden in inherited types  return linear(this,keyB,t);
		trace("Has to be overriden");
		return null;
	}

	public function angleLinear(angleA:Float, angleB:Float, spin:Int, t:Float):Float
	{
		if(spin == 0)
		{
			return angleA;
		}
		if(spin > 0)
		{
			if((angleB-angleA) < 0)
			{
				angleB += 360;
			}
		}
		else if(spin < 0)
		{
			if((angleB-angleA) > 0)
			{    
				angleB -= 360;
			}
		}

		return linear(angleA,angleB,t);
	}

	public function  quadratic(a:Float, b:Float, c:Float, t:Float):Float
	{
		return linear(linear(a,b,t),linear(b,c,t),t);
	}

	public function  cubic(a:Float, b:Float, c:Float, d:Float, t:Float):Float
	{
		return linear(quadratic(a,b,c,t),quadratic(b,c,d,t),t);
	}
}