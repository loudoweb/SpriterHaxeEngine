package spriter.vars;

/**
 * ...
 * @author Loudo
 */
class Variable<T>
{
	public var name:String;
	public var value(default,null):T;
	public var def:T;
	public function new(name:String, def:T) 
	{
		this.name = name;
		value = def;
		this.def = def;
	}
	/**
	 * 
	 * @param	value
	 * @return true if value changes
	 */
	public function set(value:String):Bool
	{
		return false;
	}
	public function toString():String
	{
		return '[var $name : v:$value, d:$def]';
	}
	
}