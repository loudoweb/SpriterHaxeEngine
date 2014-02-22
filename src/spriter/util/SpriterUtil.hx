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
	
	inline static public function fixRotation(rotation : Float) : Float 
	{
		if (rotation == 0)
			return 0;
		
		return 360 - rotation;
	}
	
	inline static public function normalizeRotation(rotation : Float) : Float 
	{
		if (rotation == 0)
			return 0;
			
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
    

	
}