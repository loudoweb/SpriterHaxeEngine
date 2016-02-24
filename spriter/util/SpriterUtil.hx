package spriter.util;

/**
 * ...
 * @author Loudo
 */
class SpriterUtil
{

	inline static public function toRadians(deg : Float) : Float
    {
        return deg * Math.PI / 180;
    }
	//because rotation on spriter vs flash are inverted
	inline static public function fixRotation(rotation : Float) : Float 
	{
		if (rotation == 0)
			rotation = 360;
		
		return 360 - rotation;
	}
	
	inline static public function under360(rotation : Float) : Float 
	{	
		while (rotation > 360)
		{
			rotation -= 360;
		}

		while (rotation < 0)
		{
			rotation += 360;
		}
		return rotation;
	}
	
	inline static public function normalizeRotation(rotation : Float) : Float
	{
		return rotation / 360;
	}
	
	inline static public function fixPivotY(pivotY : Float) : Float 
	{
		return 1 - pivotY;
	}
	
	inline static public function signOf(f:Float):Int
	{
		return (f < 0) ? -1 : 1;
	}
	
	inline static public function sameSign(f1:Float, f2:Float):Bool
	{
		return signOf(f1) == signOf(f2);
	}
	
	inline static public function clearArray(array:Array<Dynamic>):Void
	{
		if (array.length > 0)
		{
			#if cpp
			array.splice(0, array.length);//allocates in hxcpp but fastest
			#else
			untyped array.length = 0;
			#end
		}
	}
}