package spriter.definitions;
import spriter.xml.Access;

/**
 * ...
 * @author Loudo
 */
class SpriterFile
{
	public var id:Int;
	public var name:String; 
    public var pivotX:Float;
    public var pivotY:Float;
	public var width:Float;
	public var height:Float;
	
	public function new(xml:Access = null) 
	{
		if(xml != null){
			id = Std.parseInt(xml.att.id);
			name = xml.att.name;
			pivotX = xml.has.pivot_x ? Std.parseFloat(xml.att.pivot_x) : 0;
			pivotY = xml.has.pivot_y ? Std.parseFloat(xml.att.pivot_y) : 1;
			
			width = xml.has.width ? Std.parseFloat(xml.att.width) : 0;
			height = xml.has.height ? Std.parseFloat(xml.att.height) : 0;
		}
	}
	
	public function copy():SpriterFile
	{
		var copy:SpriterFile = new SpriterFile();
		copy.name = name;
		copy.id = id;
		copy.pivotX = pivotX;
		copy.pivotY = pivotY;
		copy.width = width;
		copy.height = height;
		return copy;
	}
	
}