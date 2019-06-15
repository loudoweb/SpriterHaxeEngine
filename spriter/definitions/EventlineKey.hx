package spriter.definitions;
import haxe.xml.Access;

/**
 * ...
 * @author loudo
 */
class EventlineKey
{
	public var id:Int;
	public var time:Int = 0;
	public function new(xml:Access) 
	{
		if(xml != null){
			id = xml.has.id ? Std.parseInt(xml.att.id) : 0;
			time = xml.has.time ? Std.parseInt(xml.att.time) : 0;
		}
	}
	public function copy ():EventlineKey
	{
		var	copy:EventlineKey = new EventlineKey(null);
		return clone (copy);
	}

	public function clone (clone:EventlineKey):EventlineKey
	{
		clone.id = id;
		clone.time = time;
		return clone;
	}
}