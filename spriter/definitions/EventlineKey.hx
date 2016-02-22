package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author loudo
 */
class EventlineKey
{
	public var id:Int;
	public var time:Int = 0;
	public function new(fast:Fast = null) 
	{
		if(fast != null){
			id = fast.has.id ? Std.parseInt(fast.att.id) : 0;
			time = fast.has.time ? Std.parseInt(fast.att.time) : 0;
		}
	}
	public function copy ():EventlineKey
	{
		var	copy:EventlineKey = new EventlineKey();
		return clone (copy);
	}

	public function clone (clone:EventlineKey):EventlineKey
	{
		clone.id = id;
		clone.time = time;
		return clone;
	}
}