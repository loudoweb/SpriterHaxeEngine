package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class VarlineKey
{
	public var id:Int;
	public var time:Int = 0;
	public var value:String;
	public var dispatched(get, set):Bool;
	var _dispatched:Bool = false;
	public var lastDispatched(get, set):Int;
	var _lastDispatched:Int = -1;
	public function new(fast:Fast = null) 
	{
		if(fast != null){
			id = fast.has.id ? Std.parseInt(fast.att.id) : 0;
			time = fast.has.time ? Std.parseInt(fast.att.time) : 0;
			value = fast.att.val;
		}
	}
	public function copy ():VarlineKey
	{
		var	copy:VarlineKey = new VarlineKey();
		return clone (copy);
	}

	public function clone (clone:VarlineKey):VarlineKey
	{
		clone.id = id;
		clone.time = time;
		clone.value = value;
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