package spriter.vars;

/**
 * ...
 * @author Loudo
 */
class VariableInt extends Variable<Int>
{

	public function new(name:String,value:Int) 
	{
		super(name,value);
	}
	override public function set(value:String):Bool
	{
		var temp:Int = this.value;
		this.value = Std.parseInt(value);
		if (temp != this.value)
			return true;
		return false;
	}
	
}