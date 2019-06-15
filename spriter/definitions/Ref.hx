package spriter.definitions;
import haxe.xml.Access;

/**
 * ...
 * @author Loudo
 */
class Ref
{
	public var id : Int;
	public var parent:Int; // -1==no parent - uses ScmlObject spatialInfo as parentInfo
    public var timeline:Int;
    public var key:Int;
	public var z_index:Int;
	
	public function new(xml:Access) 
	{
		id = Std.parseInt(xml.att.id);
		parent = xml.has.parent ? Std.parseInt(xml.att.parent) : -1;
		timeline = Std.parseInt(xml.att.timeline);
		key = Std.parseInt(xml.att.key);
		z_index = xml.has.z_index ? Std.parseInt(xml.att.z_index) : 0;
	}
	
}