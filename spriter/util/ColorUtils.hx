package spriter.util;

/**
 * ...
 * @author Loudo
 */
class ColorUtils
{

	/**
	 * Get int from Multiply alpha
	 * 
	 * @param	factor	 Number from 0.0 to 1.0.
	 * @return 	The lightened color
	 */
	inline public static inline function multiplyAlpha(factor:Float = 1, color:Int = 0xffffffff):Int
	{
		var r:Int = getRed(color);
		var g:Int = getGreen(color);
		var b:Int = getBlue(color);

		return makeFromARGB(factor, r, g, b);
	}
	inline public static inline function getRed(Color:Int):Int
	{
		return Color >> 16 & 0xFF;
	}
	inline public static inline function getGreen(Color:Int):Int
	{
		return Color >> 8 & 0xFF;
	}
	inline public static inline function getBlue(Color:Int):Int
	{
		return Color & 0xFF;
	}
	inline public static inline function makeFromARGB(alpha:Float = 1.0, r:Int, g:Int, b:Int):Int
	{
		return (Std.int((alpha > 1) ? alpha : (alpha * 255)) & 0xFF) << 24 | (r & 0xFF) << 16 | (g & 0xFF) << 8 | (b & 0xFF);
	}
	
}