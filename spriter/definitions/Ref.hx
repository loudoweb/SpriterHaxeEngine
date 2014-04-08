package spriter.definitions;
import haxe.xml.Fast;

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
	
	public function new(fast:Fast) 
	{
		id = Std.parseInt(fast.att.id);
		parent = fast.has.parent ? Std.parseInt(fast.att.parent) : -1;
		timeline = Std.parseInt(fast.att.timeline);
		key = Std.parseInt(fast.att.key);
	}
	
}