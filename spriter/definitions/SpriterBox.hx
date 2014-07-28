package spriter.definitions;
import haxe.xml.Fast;

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
	
	public function new(fast:Fast = null) 
	{
		if(fast != null){
			name = fast.att.name;
			pivotX = fast.has.pivot_x ? Std.parseFloat(fast.att.pivot_x) : 0;
			pivotY = fast.has.pivot_y ? Std.parseFloat(fast.att.pivot_y) : 0;
			
			width = fast.has.w ? Std.parseFloat(fast.att.w) : 0;
			height = fast.has.h ? Std.parseFloat(fast.att.h) : 0;
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