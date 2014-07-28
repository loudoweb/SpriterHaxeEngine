package spriter.vars;

/**
 * ...
 * @author Loudo
 */
class VariableFloat extends Variable<Float>
{

	public function new(name:String,value:Float) 
	{
		super(name,value);
	}
	override public function set(value:String):Bool
	{
		var temp = this.value;
		this.value = Std.parseFloat(value);
		if (temp != this.value)
			return true;
		return false;
	}
	
}