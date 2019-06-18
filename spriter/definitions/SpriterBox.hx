package spriter.definitions;
import spriter.xml.Access;

/**
 * ...
 * @author Loudo
 */
class SpriterBox
{
	public var name:String; 
    public var pivotX:Float;
    public var pivotY:Float;
	public var width:Float;
	public var height:Float;
	
	public function new(xml:Access = null) 
	{
		if(xml != null){
			name = xml.att.name;
			pivotX = xml.has.pivot_x ? Std.parseFloat(xml.att.pivot_x) : 0;
			pivotY = xml.has.pivot_y ? Std.parseFloat(xml.att.pivot_y) : 0;
			
			width = xml.has.w ? Std.parseFloat(xml.att.w) : 0;
			height = xml.has.h ? Std.parseFloat(xml.att.h) : 0;
		}
	}
	
	public function copy():SpriterBox
	{
		var copy:SpriterBox = new SpriterBox();
		copy.name = name;
		copy.pivotX = pivotX;
		copy.pivotY = pivotY;
		copy.width = width;
		copy.height = height;
		return copy;
	}
	
}