package spriter.vars;

/**
 * ...
 * @author Loudo
 */
class VariableString extends Variable<String>
{

	public function new(name:String,value:String) 
	{
		super(name,value);
	}
	override public function set(value:String):Bool
	{
		var temp:String = this.value;
		this.value = value;
		if (temp != this.value)
			return true;
		return false;
	}
	
}