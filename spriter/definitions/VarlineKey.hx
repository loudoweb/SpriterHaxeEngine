package spriter.definitions;
import haxe.xml.Fast;

/**
 * ...
 * @author Loudo
 */
class VarlineKey extends TimelineKey
{
	public var value:String;
	public function new(fast:Fast = null) 
	{
		if(fast != null){
			value = fast.att.val;
		}
		super(fast);
	}
	
	override public function copy ():TimelineKey
	{
		var	copy:TimelineKey = new VarlineKey();
		return clone (copy);
	}

	override public function clone (clone:TimelineKey):TimelineKey
	{
		super.clone(clone);
		var	c:VarlineKey = cast clone;
		c.value = value;
		return c;
	}
}