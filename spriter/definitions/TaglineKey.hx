package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class TaglineKey
{
	public var id:Int;
	public var time:Int = 0;
	public var t:Int;
	public var dispatched(get, set):Bool;
	var _dispatched:Bool = false;
	public var lastDispatched(get, set):Int;
	var _lastDispatched:Int = -1;
	public function new(fast:Fast = null) 
	{
		if(fast != null){
			id = fast.has.id ? Std.parseInt(fast.att.id) : 0;
			time = fast.has.time ? Std.parseInt(fast.att.time) : 0;
			fast = fast.node.tag;
			t = Std.parseInt(fast.att.t);
		}
	}
	public function copy ():TaglineKey
	{
		var	copy:TaglineKey = new TaglineKey();
		return clone (copy);
	}

	public function clone (clone:TaglineKey):TaglineKey
	{
		clone.id = id;
		clone.time = time;
		clone.t = t;
		return clone;
	}
	public function set_lastDispatched(val:Int):Int
	{
		_lastDispatched = val;
		_dispatched = val != -1;
		return val;
	}
	public function get_lastDispatched():Int
	{
		return _lastDispatched;
	}
	public function set_dispatched(val:Bool):Bool
	{
		_dispatched = val;
		if (!val)
			_lastDispatched = -1;
		return val;
	}
	public function get_dispatched():Bool
	{
		return _dispatched;
	}
	
}