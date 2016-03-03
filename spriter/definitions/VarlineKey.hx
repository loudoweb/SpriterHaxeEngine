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
		super(fast, VARIABLE);
	}
}