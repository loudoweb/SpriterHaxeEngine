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
		this.value = def;
		this.def = def;
	}
	/**
	 * Update the var
	 * @param	value
	 * @return true if value changes
	 */
	public function set(value:String):Bool
	{
		return false;
	}
	/**
	 * Don't update the var but get the value in the right format (float, int, string).
	 * @param	value
	 * @return
	 */
	public function convert(value:String):T
	{
		return null;
	}
	public function toString():String
	{
		return '[var $name : v:$value, d:$def]';
	}
	
}